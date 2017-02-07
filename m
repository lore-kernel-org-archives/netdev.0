From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [PATCH v3 4/5] samples/bpf: Reset global variables
Date: Tue,  7 Feb 2017 21:56:08 +0100
Message-ID: <20170207205609.8035-5-mic@digikod.net>
References: <20170207205609.8035-1-mic@digikod.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@fb.com>,
        Arnaldo Carvalho de Melo <acme@redhat.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        "David S . Miller" <davem@davemloft.net>,
        Joe Stringer <joe@ovn.org>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170207205609.8035-1-mic@digikod.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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
