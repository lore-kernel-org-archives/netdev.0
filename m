From: Florian Fainelli <f.fainelli@gmail.com>
Subject: [PATCH net-next v4 05/13] net: dsa: retain a per-port device_node pointer
Date: Mon, 25 Aug 2014 21:49:33 -0700
Message-ID: <1409028581-17399-6-git-send-email-f.fainelli@gmail.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Cc: Florian Fainelli <f.fainelli@gmail.com>, davem@davemloft.net,
	linville@tuxdriver.com, jhs@mojatatu.com, alexander.duyck@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:59593 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755444AbaHZEud (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 00:50:33 -0400
Received: by mail-pa0-f45.google.com with SMTP id eu11so22600753pac.4
        for <netdev@vger.kernel.org>; Mon, 25 Aug 2014 21:50:32 -0700 (PDT)
In-Reply-To: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We will later use the per-port device_node pointer to fetch a bunch of
port-specific properties.

Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
---
Changes in v2, v3, v4:
- respin

 include/net/dsa.h | 1 +
 net/dsa/dsa.c     | 2 ++
 net/dsa/slave.c   | 1 +
 3 files changed, 4 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index decc62709acd..597875d3f69e 100644
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
index 1ad18cfd1a3e..e3a1ec109a01 100644
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
index ad1a913533aa..5688c34253e5 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -354,6 +354,7 @@ dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	}
 
 	SET_NETDEV_DEV(slave_dev, parent);
+	slave_dev->dev.of_node = ds->pd->port_dn[port];
 	slave_dev->vlan_features = master->vlan_features;
 
 	p = netdev_priv(slave_dev);
-- 
1.9.1
