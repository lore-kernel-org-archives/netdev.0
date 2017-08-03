From: Edward Cree via iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
Subject: [PATCH v4 net-next 13/13] bpf/verifier: increase
 complexity limit to 128k
Date: Thu, 3 Aug 2017 17:16:24 +0100
Message-ID: <059b056e-178a-da21-cc68-47802eba29a3@solarflare.com>
References: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2@solarflare.com>
Reply-To: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, iovisor-dev <iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>, Alexei Starovoitov <alexei.starovoitov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Alexei Starovoitov <ast-b10kYP2dOMg@public.gmane.org>, Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
Return-path: <iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
In-Reply-To: <22441d84-0a11-5c00-2d2a-25e7dbafa6c2-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
List-Unsubscribe: <https://lists.iovisor.org/mailman/options/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.iovisor.org/pipermail/iovisor-dev/>
List-Post: <mailto:iovisor-dev-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org>
List-Help: <mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=help>
List-Subscribe: <https://lists.iovisor.org/mailman/listinfo/iovisor-dev>,
	<mailto:iovisor-dev-request-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org?subject=subscribe>
Sender: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
Errors-To: iovisor-dev-bounces-9jONkmmOlFHEE9lA1F8Ukti2O/JbrIOy@public.gmane.org
List-Id: netdev.vger.kernel.org

The more detailed value tracking can reduce the effectiveness of pruning
 for some programs.  So, to avoid rejecting previously valid programs, up
 the limit to 128kinsns.  Hopefully we will be able to bring this back
 down later by improving pruning performance.

Signed-off-by: Edward Cree <ecree-s/n/eUQHGBpZroRs9YW3xA@public.gmane.org>
---
 kernel/bpf/verifier.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/bpf/verifier.c b/kernel/bpf/verifier.c
index 2924b01..2cc3894 100644
--- a/kernel/bpf/verifier.c
+++ b/kernel/bpf/verifier.c
@@ -140,7 +140,7 @@ struct bpf_verifier_stack_elem {
 	struct bpf_verifier_stack_elem *next;
 };
 
-#define BPF_COMPLEXITY_LIMIT_INSNS	98304
+#define BPF_COMPLEXITY_LIMIT_INSNS	131072
 #define BPF_COMPLEXITY_LIMIT_STACK	1024
 
 #define BPF_MAP_PTR_POISON ((void *)0xeB9F + POISON_POINTER_DELTA)
