From: Florian Fainelli <florian@openwrt.org>
Subject: [PATCH 2/2] dsa: make dsa_switch_setup check for valid port names
Date: Mon, 21 Jan 2013 20:58:51 +0100
Message-ID: <1358798331-13055-3-git-send-email-florian@openwrt.org>
References: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Cc: buytenh@wantstofly.org, konszert@marvell.com, davem@davemloft.net,
	Florian Fainelli <florian@openwrt.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from zmc.proxad.net ([212.27.53.206]:43894 "EHLO zmc.proxad.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755967Ab3AUUBi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 15:01:38 -0500
In-Reply-To: <1358798331-13055-1-git-send-email-florian@openwrt.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes dsa_switch_setup() to ensure that at least one valid
valid port name is specified and will bail out with an error in case we
walked the maximum number of port with a valid port name found.

Signed-off-by: Florian Fainelli <florian@openwrt.org>
---
 net/dsa/dsa.c |    6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 45295ca..2bc62ea 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -80,6 +80,7 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 	int ret;
 	char *name;
 	int i;
+	bool valid_name_found = false;
 
 	/*
 	 * Probe for switch model.
@@ -131,8 +132,13 @@ dsa_switch_setup(struct dsa_switch_tree *dst, int index,
 		} else {
 			ds->phys_port_mask |= 1 << i;
 		}
+		valid_name_found = true;
 	}
 
+	if (!valid_name_found && i == DSA_MAX_PORTS) {
+		ret = -EINVAL;
+		goto out;
+	}
 
 	/*
 	 * If the CPU connects to this switch, set the switch tree
-- 
1.7.10.4
