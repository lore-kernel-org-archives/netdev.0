From: Stephen Boyd <sboyd@codeaurora.org>
Subject: [PATCH] net: Silence seq_scale() unused warning
Date: Mon,  5 Dec 2011 10:29:56 -0800
Message-ID: <1323109796-31084-1-git-send-email-sboyd@codeaurora.org>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On a CONFIG_NET=y build

net/core/secure_seq.c:22: warning: 'seq_scale' defined but not
used

Signed-off-by: Stephen Boyd <sboyd@codeaurora.org>
---

I don't know how realistic this configuration is, but here it goes.

 net/core/secure_seq.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/core/secure_seq.c b/net/core/secure_seq.c
index 025233d..db12233 100644
--- a/net/core/secure_seq.c
+++ b/net/core/secure_seq.c
@@ -19,6 +19,7 @@ static int __init net_secret_init(void)
 }
 late_initcall(net_secret_init);
 
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE) || defined(CONFIG_INET)
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
