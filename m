From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v4 1/3] samples/bpf: Ignore already processed ELF sections
Date: Wed,  8 Feb 2017 21:27:42 +0100
Message-ID: <20170208202744.16274-2-mic@digikod.net>
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
Received: from smtp-sh2.infomaniak.ch ([128.65.195.6]:49059 "EHLO
        smtp-sh2.infomaniak.ch" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751059AbdBHUa1 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:30:27 -0500
In-Reply-To: <20170208202744.16274-1-mic@digikod.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a missing check for the map fixup loop.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
---
 samples/bpf/bpf_load.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/samples/bpf/bpf_load.c b/samples/bpf/bpf_load.c
index 396e204888b3..e04fe09d7c2e 100644
--- a/samples/bpf/bpf_load.c
+++ b/samples/bpf/bpf_load.c
@@ -328,6 +328,8 @@ int load_bpf_file(char *path)
 
 	/* load programs that need map fixup (relocations) */
 	for (i = 1; i < ehdr.e_shnum; i++) {
+		if (processed_sec[i])
+			continue;
 
 		if (get_sec(elf, i, &ehdr, &shname, &shdr, &data))
 			continue;
-- 
2.11.0
