From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCHv2] net: Silence seq_scale() unused warning
Date: Tue,  6 Dec 2011 10:04:40 -0800
Message-ID: <1323194680-32127-1-git-send-email-sboyd@codeaurora.org>
References: <20111206.003157.159978113328078893.davem@davemloft.net>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111206.003157.159978113328078893.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a CONFIG_NET=y build

net/core/secure_seq.c:22: warning: 'seq_scale' defined but not
used

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---

On 12/5/2011 9:31 PM, David Miller wrote:
> Just test INET all by itself, IPV6 will always need the INET
> infrastructure for hash tables and inet socket management even in the
> extremely unlikely event that we make ipv4 independently selectable at
> some point.

Ok.

 net/core/secure_seq.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 025233d..925991a 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -19,6 +19,7 @@ static int __init net_secret_init(void)
 }
 late_initcall(net_secret_init);
 
+#ifdef CONFIG_INET
 static u32 seq_scale(u32 seq)
 {
 	/*
@@ -33,6 +34,7 @@ static u32 seq_scale(u32 seq)
 	 */
 	return seq + (ktime_to_ns(ktime_get_real()) >> 6);
 }
+#endif
 
 #if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
 __u32 secure_tcpv6_sequence_number(const __be32 *saddr, const __be32 *daddr,
-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora Forum.
