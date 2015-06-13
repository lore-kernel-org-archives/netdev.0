From: sfeldma@gmail.com
Subject: [PATCH net-next 3/5] rocker: mark STP update as 'no wait' processing
Date: Fri, 12 Jun 2015 21:35:48 -0700
Message-ID: <1434170150-63838-4-git-send-email-sfeldma@gmail.com>
References: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, simon.horman@netronome.com,
	makita.toshiaki@lab.ntt.co.jp
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:35202 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751005AbbFMEeF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Jun 2015 00:34:05 -0400
Received: by iesa3 with SMTP id a3so34891302ies.2
        for <netdev@vger.kernel.org>; Fri, 12 Jun 2015 21:34:04 -0700 (PDT)
In-Reply-To: <1434170150-63838-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

We can get STP updates from the bridge driver in atomic and non-atomic
contexts.  Since we can't test what context we're getting called in,
do the STP processing as 'no wait', which will cover all cases.

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |    3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index 1995b59..6c15c2e 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4286,7 +4286,8 @@ static int rocker_port_attr_set(struct net_device *dev,
 
 	switch (attr->id) {
 	case SWITCHDEV_ATTR_PORT_STP_STATE:
-		err = rocker_port_stp_update(rocker_port, attr->trans, 0,
+		err = rocker_port_stp_update(rocker_port, attr->trans,
+					     ROCKER_OP_FLAG_NOWAIT,
 					     attr->u.stp_state);
 		break;
 	case SWITCHDEV_ATTR_PORT_BRIDGE_FLAGS:
-- 
1.7.10.4
