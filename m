From: Arnaldo Carvalho de Melo <acme@kernel.org>
Subject: [PATCH 14/15] samples/bpf: Ignore already processed ELF sections
Date: Mon, 13 Feb 2017 22:13:59 -0300
Message-ID: <20170214011400.13352-15-acme@kernel.org>
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

Add a missing check for the map fixup loop.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Acked-by: Joe Stringer <joe@ovn.org>
Acked-by: Wang Nan <wangnan0@huawei.com>
Cc: Alexei Starovoitov <ast@fb.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: David S. Miller <davem@davemloft.net>
Cc: netdev@vger.kernel.org
Link: http://lkml.kernel.org/r/20170208202744.16274-2-mic@digikod.net
Signed-off-by: Arnaldo Carvalho de Melo <acme@redhat.com>
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
2.9.3
