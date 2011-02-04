From: David Miller <davem@davemloft.net>
Subject: [PATCH] net: Fix bug in compat SIOCGETSGCNT handling.
Date: Thu, 03 Feb 2011 17:54:43 -0800 (PST)
Message-ID: <20110203.175443.102558250.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, ebiederm@xmission.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:40087
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755270Ab1BDByI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Feb 2011 20:54:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Commit 709b46e8d90badda1898caea50483c12af178e96 ("net: Add compat
ioctl support for the ipv4 multicast ioctl SIOCGETSGCNT") added the
correct plumbing to handle SIOCGETSGCNT properly.

However, whilst definiting a proper "struct compat_sioc_sg_req" it
isn't actually used in ipmr_compat_ioctl().

Correct this oversight.

Signed-off-by: David S. Miller <davem@davemloft.net>
---
 net/ipv4/ipmr.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 7e41ac0..fce10a0 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -1446,7 +1446,7 @@ struct compat_sioc_sg_req {
 
 int ipmr_compat_ioctl(struct sock *sk, unsigned int cmd, void __user *arg)
 {
-	struct sioc_sg_req sr;
+	struct compat_sioc_sg_req sr;
 	struct mfc_cache *c;
 	struct net *net = sock_net(sk);
 	struct mr_table *mrt;
-- 
1.7.4

