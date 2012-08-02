From: Dragos Ilie <dragos.ilie@gmail.com>
Subject: [PATCH] ipv6: Fix premature timeout for MLDv1 compatibility mode
Date: Thu,  2 Aug 2012 09:51:06 +0200
Message-ID: <1343893866-20940-1-git-send-email-dragos.ilie@gmail.com>
Cc: Dragos Ilie <dragos.ilie@gmail.com>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The timeout for MLDv1 compatibility mode is now calculated according
to Section 9.2 in RFC 3810.

Signed-off-by: Dragos Ilie <dragos.ilie@gmail.com>
---
 net/ipv6/mcast.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/net/ipv6/mcast.c b/net/ipv6/mcast.c
index 92f8e48..ef824a0 100644
--- a/net/ipv6/mcast.c
+++ b/net/ipv6/mcast.c
@@ -109,6 +109,7 @@ static int ip6_mc_leave_src(struct sock *sk, struct ipv6_mc_socklist *iml,
 
 #define IGMP6_UNSOLICITED_IVAL	(10*HZ)
 #define MLD_QRV_DEFAULT		2
+#define MLD_QIVAL_DEFAULT       (125*HZ)
 
 #define MLD_V1_SEEN(idev) (dev_net((idev)->dev)->ipv6.devconf_all->force_mld_version == 1 || \
 		(idev)->cnf.force_mld_version == 1 || \
@@ -1152,7 +1153,7 @@ int igmp6_event_query(struct sk_buff *skb)
 		/* Translate milliseconds to jiffies */
 		max_delay = (ntohs(mld->mld_maxdelay)*HZ)/1000;
 
-		switchback = (idev->mc_qrv + 1) * max_delay;
+		switchback = (idev->mc_qrv * MLD_QIVAL_DEFAULT) + max_delay;
 		idev->mc_v1_seen = jiffies + switchback;
 
 		/* cancel the interface change timer */
-- 
1.7.8.6
