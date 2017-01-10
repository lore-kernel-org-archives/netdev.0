From: Andy Lutomirski <luto@kernel.org>
Subject: [PATCH v2 6/8] bpf: Rename fdinfo's prog_digest to prog_sha256
Date: Tue, 10 Jan 2017 15:24:44 -0800
Message-ID: <1bdf42122bb49855ab21ede91b25423dad635d01.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Cc: "Jason A. Donenfeld" <Jason@zx2c4.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Eric Dumazet <edumazet@google.com>,
        Eric Biggers <ebiggers3@gmail.com>,
        Tom Herbert <tom@herbertland.com>,
        "David S. Miller" <davem@davemloft.net>,
        Andy Lutomirski <luto@kernel.org>,
        Alexei Starovoitov <ast@kernel.org>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>,
        Linux Crypto Mailing List <linux-crypto@vger.kernel.org>
Return-path: <linux-crypto-owner@vger.kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
In-Reply-To: <cover.1484090585.git.luto@kernel.org>
References: <cover.1484090585.git.luto@kernel.org>
Sender: linux-crypto-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This makes it easier to add another digest algorithm down the road
if needed.  It also serves to force any programs that might have
been written against a kernel that had 'prog_digest' to be updated.

This shouldn't violate any stable API policies, as no released
kernel has ever had 'prog_digest'.

Cc: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@kernel.org>
Signed-off-by: Andy Lutomirski <luto@kernel.org>
---
 kernel/bpf/syscall.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index e89acea22ecf..956370b80296 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -694,7 +694,7 @@ static void bpf_prog_show_fdinfo(struct seq_file *m, struct file *filp)
 	seq_printf(m,
 		   "prog_type:\t%u\n"
 		   "prog_jited:\t%u\n"
-		   "prog_digest:\t%s\n"
+		   "prog_sha256:\t%s\n"
 		   "memlock:\t%llu\n",
 		   prog->type,
 		   prog->jited,
-- 
2.9.3
