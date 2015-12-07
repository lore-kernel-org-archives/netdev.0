From: Russell King <rmk+kernel@arm.linux.org.uk>
Subject: [PATCH RFC 17/26] phylink: add ethtool nway_reset support
Date: Mon, 07 Dec 2015 17:38:38 +0000
Message-ID: <E1a5zkE-00076C-He@rmk-PC.arm.linux.org.uk>
References: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pandora.arm.linux.org.uk ([78.32.30.218]:60302 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932603AbbLGRil (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Dec 2015 12:38:41 -0500
In-Reply-To: <20151207173553.GU8644@n2100.arm.linux.org.uk>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add ethtool nway_reset support to phylink, to allow userspace to
request a re-negotiation of the link.

Signed-off-by: Russell King <rmk+kernel@arm.linux.org.uk>
---
 drivers/net/phy/phylink.c | 14 ++++++++++++++
 include/linux/phylink.h   |  1 +
 2 files changed, 15 insertions(+)

diff --git a/drivers/net/phy/phylink.c b/drivers/net/phy/phylink.c
index 7d56e5895087..908235fb16c1 100644
--- a/drivers/net/phy/phylink.c
+++ b/drivers/net/phy/phylink.c
@@ -659,6 +659,20 @@ int phylink_ethtool_set_settings(struct phylink *pl, struct ethtool_cmd *cmd)
 }
 EXPORT_SYMBOL_GPL(phylink_ethtool_set_settings);
 
+int phylink_ethtool_nway_reset(struct phylink *pl)
+{
+	int ret = 0;
+
+	mutex_lock(&pl->config_mutex);
+	if (pl->phydev)
+		ret = genphy_restart_aneg(pl->phydev);
+	pl->ops->mac_an_restart(pl->netdev, pl->link_an_mode);
+	mutex_unlock(&pl->config_mutex);
+
+	return ret;
+}
+EXPORT_SYMBOL_GPL(phylink_ethtool_nway_reset);
+
 /* This emulates MII registers for a fixed-mode phy operating as per the
  * passed in state. "aneg" defines if we report negotiation is possible.
  *
diff --git a/include/linux/phylink.h b/include/linux/phylink.h
index c7a665a538c1..ad3c85508d19 100644
--- a/include/linux/phylink.h
+++ b/include/linux/phylink.h
@@ -65,6 +65,7 @@ void phylink_stop(struct phylink *);
 
 int phylink_ethtool_get_settings(struct phylink *, struct ethtool_cmd *);
 int phylink_ethtool_set_settings(struct phylink *, struct ethtool_cmd *);
+int phylink_ethtool_nway_reset(struct phylink *);
 int phylink_mii_ioctl(struct phylink *, struct ifreq *, int);
 
 void phylink_set_link_port(struct phylink *pl, u32 support, u8 port);
-- 
2.1.0
