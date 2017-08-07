From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH v5 net-next 12/12] bpf/verifier: increase complexity limit to
 128k
Date: Mon, 7 Aug 2017 15:30:30 +0100
Message-ID: <f72c4d22-2df5-6a59-a1b9-281686876e83@solarflare.com>
References: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
        iovisor-dev <iovisor-dev@lists.iovisor.org>
To: <davem@davemloft.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        Daniel Borkmann <daniel@iogearbox.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <ad840039-8d4a-b2a9-b2eb-a8f079926b53@solarflare.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The more detailed value tracking can reduce the effectiveness of pruning
 for some programs.  So, to avoid rejecting previously valid programs, up
 the limit to 128kinsns.  Hopefully we will be able to bring this back
 down later by improving pruning performance.

Signed-off-by: Edward Cree <ecree@solarflare.com>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 08a6fa0..8160a81 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -140,7 +140,7 @@ struct bpf_verifier_stack_elem {
 	struct bpf_verifier_stack_elem *next;
 };
 
-#define BPF_COMPLEXITY_LIMIT_INSNS	98304
+#define BPF_COMPLEXITY_LIMIT_INSNS	131072
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
 #define BPF_MAP_PTR_POISON ((void *)0xeB9F + POISON_POINTER_DELTA)
