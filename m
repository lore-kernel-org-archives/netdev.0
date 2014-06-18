From: Kees Cook <keescook@chromium.org>
Subject: [PATCH] net: filter: fix upper BPF instruction limit
Date: Wed, 18 Jun 2014 15:34:57 -0700
Message-ID: <20140618223457.GA31568@www.outflux.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexei Starovoitov <ast@plumgrid.com>,
	Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <edumazet@google.com>,
	Chema Gonzalez <chema@google.com>, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The original checks (via sk_chk_filter) for instruction count uses ">",
not ">=", so changing this in sk_convert_filter has the potential to break
existing seccomp filters that used exactly BPF_MAXINSNS many instructions.

Fixes: bd4cf0ed331a ("net: filter: rework/optimize internal BPF interpreter's instruction set")
Signed-off-by: Kees Cook <keescook@chromium.org>
Cc: stable@vger.kernel.org # v3.15+
---
 net/core/filter.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 735fad897496..a44e12cdde4c 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -840,7 +840,7 @@ int sk_convert_filter(struct sock_filter *prog, int len,
 	BUILD_BUG_ON(BPF_MEMWORDS * sizeof(u32) > MAX_BPF_STACK);
 	BUILD_BUG_ON(BPF_REG_FP + 1 != MAX_BPF_REG);
 
-	if (len <= 0 || len >= BPF_MAXINSNS)
+	if (len <= 0 || len > BPF_MAXINSNS)
 		return -EINVAL;
 
 	if (new_prog) {
-- 
1.7.9.5


-- 
Kees Cook
Chrome OS Security
