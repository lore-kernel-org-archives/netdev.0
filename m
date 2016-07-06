From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH/RFC net-next 4/4] mpls: allow routes on ipip and sit devices
Date: Wed,  6 Jul 2016 20:22:35 +0200
Message-ID: <1467829355-4498-5-git-send-email-simon.horman@netronome.com>
References: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f49.google.com ([74.125.82.49]:35250 "EHLO
	mail-wm0-f49.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754706AbcGFSW7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Jul 2016 14:22:59 -0400
Received: by mail-wm0-f49.google.com with SMTP id z126so121551547wme.0
        for <netdev@vger.kernel.org>; Wed, 06 Jul 2016 11:22:58 -0700 (PDT)
Received: from penelope.isobedori.kobe.vergenet.net (dhcp-077-251-078-056.chello.nl. [77.251.78.56])
        by smtp.gmail.com with ESMTPSA id m5sm629757wmm.10.2016.07.06.11.22.55
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-SHA bits=128/128);
        Wed, 06 Jul 2016 11:22:56 -0700 (PDT)
In-Reply-To: <1467829355-4498-1-git-send-email-simon.horman@netronome.com>
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
