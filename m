From: sfeldma@gmail.com
Subject: [PATCH net-next v3 05/26] rocker: use swdev get/set attr for bridge port flags
Date: Thu,  2 Apr 2015 01:09:51 -0700
Message-ID: <1427962212-18411-6-git-send-email-sfeldma@gmail.com>
References: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Cc: jiri@resnulli.us, roopa@cumulusnetworks.com, linux@roeck-us.net,
	f.fainelli@gmail.com, sridhar.samudrala@intel.com,
	ronen.arad@intel.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f179.google.com ([209.85.192.179]:34087 "EHLO
	mail-pd0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753054AbbDBIJ1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Apr 2015 04:09:27 -0400
Received: by pdbni2 with SMTP id ni2so82128573pdb.1
        for <netdev@vger.kernel.org>; Thu, 02 Apr 2015 01:09:26 -0700 (PDT)
In-Reply-To: <1427962212-18411-1-git-send-email-sfeldma@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <sfeldma@gmail.com>

Signed-off-by: Scott Feldman <sfeldma@gmail.com>
---
 drivers/net/ethernet/rocker/rocker.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

diff --git a/drivers/net/ethernet/rocker/rocker.c b/drivers/net/ethernet/rocker/rocker.c
index d2015ba..c9b5299 100644
--- a/drivers/net/ethernet/rocker/rocker.c
+++ b/drivers/net/ethernet/rocker/rocker.c
@@ -4230,6 +4230,9 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 		attr->ppid.id_len = sizeof(rocker->hw.id);
 		memcpy(&attr->ppid.id, &rocker->hw.id, attr->ppid.id_len);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		attr->brport_flags = rocker_port->brport_flags;
+		break;
 	default:
 		return -EOPNOTSUPP;
 	}
@@ -4240,6 +4243,7 @@ static int rocker_port_attr_get(struct net_device *dev, struct swdev_attr *attr)
 static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 {
 	struct rocker_port *rocker_port = netdev_priv(dev);
+	unsigned long orig_flags;
 	int err = 0;
 
 	if (attr->flags & SWDEV_F_TRANS_PREPARE)
@@ -4249,6 +4253,12 @@ static int rocker_port_attr_set(struct net_device *dev, struct swdev_attr *attr)
 	case SWDEV_ATTR_PORT_STP_STATE:
 		err = rocker_port_stp_update(rocker_port, attr->stp_state);
 		break;
+	case SWDEV_ATTR_PORT_BRIDGE_FLAGS:
+		orig_flags = rocker_port->brport_flags;
+		rocker_port->brport_flags = attr->brport_flags;
+		if ((orig_flags ^ rocker_port->brport_flags) & BR_LEARNING)
+			err = rocker_port_set_learning(rocker_port);
+		break;
 	default:
 		err = -EOPNOTSUPP;
 		break;
-- 
1.7.10.4
