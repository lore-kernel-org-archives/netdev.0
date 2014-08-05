From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v2 04/12] net: dsa: retain a per-port device_node pointer
Date: Tue,  5 Aug 2014 15:31:38 -0700
Message-ID: <1407277906-19989-5-git-send-email-f.fainelli@gmail.com>
References: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Cc: davem@davemloft.net, linville@tuxdriver.com,
	Florian Fainelli <f.fainelli@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:61846 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753766AbaHEWcJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Aug 2014 18:32:09 -0400
Received: by mail-pa0-f43.google.com with SMTP id lf10so2193514pab.16
        for <netdev@vger.kernel.org>; Tue, 05 Aug 2014 15:32:09 -0700 (PDT)
In-Reply-To: <1407277906-19989-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will later use the per-port device_node pointer to fetch a bunch of
port-specific properties.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2:
- assign slave_dev->dev.of_node for various OF routines to work correctly

 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 2 ++
 net/dsa/slave.c   | 1 +
 3 files changed, 4 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 9a16c5290738..c435eaa772d5 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -41,6 +41,7 @@ struct dsa_chip_data {
 	 * or any other string to indicate this is a physical port.
 	 */
 	char		*port_names[DSA_MAX_PORTS];
+	struct device_node *port_dn[DSA_MAX_PORTS];
 
 	/*
 	 * An array (with nr_chips elements) of which element [a]
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 069586547cf5..788b2b2f39f2 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -432,6 +432,8 @@ static int dsa_of_probe(struct platform_device *pdev)
 			if (!port_name)
 				continue;
 
+			cd->port_dn[port_index] = port;
+
 			cd->port_names[port_index] = kstrdup(port_name,
 					GFP_KERNEL);
 			if (!cd->port_names[port_index]) {
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 45a1e34c89e0..9e4d3816c54e 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -371,6 +371,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
+	slave_dev->dev.of_node = ds->pd->port_dn[port];
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-- 
1.9.1
