From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH net-next v1 2/7] samples/bpf: Ignore already processed ELF sections
Date: Mon,  6 Feb 2017 00:14:23 +0100
Message-ID: <20170205231428.23846-2-mic@digikod.net>
References: <20170205231428.23846-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        netdev@vger.kernel.org, Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170205231428.23846-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
