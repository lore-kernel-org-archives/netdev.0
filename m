From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v2 4/4] mpls: allow routes on ipip and sit devices
Date: Thu,  7 Jul 2016 07:56:15 +0200
Message-ID: <1467870975-28003-5-git-send-email-simon.horman@netronome.com>
References: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Cc: Tom Herbert <tom@herbertland.com>, netdev@vger.kernel.org,
	Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f48.google.com ([74.125.82.48]:37593 "EHLO
	mail-wm0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751179AbcGGF4c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jul 2016 01:56:32 -0400
Received: by mail-wm0-f48.google.com with SMTP id a66so18030458wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 22:56:32 -0700 (PDT)
In-Reply-To: <1467870975-28003-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Allow MPLS routes on IPIP and SIT devices now that they
support forwarding MPLS packets.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Dinan Gunawardena <dinan.gunawardena@netronome.com>
---
 net/mpls/af_mpls.c | 6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/mpls/af_mpls.c b/net/mpls/af_mpls.c
index e9beaa58573c..5c161e7759b5 100644
--- a/net/mpls/af_mpls.c
+++ b/net/mpls/af_mpls.c
@@ -1009,10 +1009,12 @@ static int mpls_dev_notify(struct notifier_block *this, unsigned long event,
 	unsigned int flags;
 
 	if (event == NETDEV_REGISTER) {
-		/* For now just support Ethernet and IPGRE devices */
+		/* For now just support Ethernet, IPGRE, SIT and IPIP devices */
 		if (dev->type == ARPHRD_ETHER ||
 		    dev->type == ARPHRD_LOOPBACK ||
-		    dev->type == ARPHRD_IPGRE) {
+		    dev->type == ARPHRD_IPGRE ||
+		    dev->type == ARPHRD_SIT ||
+		    dev->type == ARPHRD_TUNNEL) {
 			mdev = mpls_add_dev(dev);
 			if (IS_ERR(mdev))
 				return notifier_from_errno(PTR_ERR(mdev));
-- 
2.7.0.rc3.207.g0ac5344
