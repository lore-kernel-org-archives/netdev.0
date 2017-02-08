From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v4 2/3] samples/bpf: Reset global variables
Date: Wed,  8 Feb 2017 21:27:43 +0100
Message-ID: <20170208202744.16274-3-mic@digikod.net>
References: <20170208202744.16274-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, Wang Nan <wangnan0@huawei.com>,
        netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:50156 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751073AbdBHUa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:30:27 -0500
In-Reply-To: <20170208202744.16274-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Before loading a new ELF, clean previous kernel version, license and
processed sections.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
---
 samples/bpf/bpf_load.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index e04fe09d7c2e..b86ee54da2d1 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -277,6 +277,11 @@ int load_bpf_file(char *path)
 	Elf_Data *data, *data_prog, *symbols = NULL;
 	char *shname, *shname_prog;
 
+	/* reset global variables */
+	kern_version = 0;
+	memset(license, 0, sizeof(license));
+	memset(processed_sec, 0, sizeof(processed_sec));
+
 	if (elf_version(EV_CURRENT) == EV_NONE)
 		return 1;
 
-- 
2.11.0
