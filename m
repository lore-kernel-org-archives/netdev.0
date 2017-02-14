From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 15/15] samples/bpf: Reset global variables
Date: Mon, 13 Feb 2017 22:14:00 -0300
Message-ID: <20170214011400.13352-16-acme@kernel.org>
References: <20170214011400.13352-1-acme@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-kernel@vger.kernel.org,
        =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Arnaldo Carvalho de Melo <acme@redhat.com>
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170214011400.13352-1-acme@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mickaël Salaün <mic@digikod.net>

Before loading a new ELF, clean previous kernel version, license and
processed sections.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170208202744.16274-3-mic@digikod.net
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
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
2.9.3
