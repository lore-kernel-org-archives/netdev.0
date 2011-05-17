From: Ben Hutchings <bhutchings@solarflare.com>
Subject: [PATCH net-next-2.6] sfc: Replace enum efx_fc_type with macros and
 type alias
Date: Tue, 17 May 2011 22:43:31 +0100
Message-ID: <1305668611.2848.58.camel@bwh-desktop>
References: <1305658121.2848.29.camel@bwh-desktop>
	 <20110517.152651.1785846817320651943.davem@davemloft.net>
	 <1305666379.2848.45.camel@bwh-desktop>
	 <20110517.171412.1017451005914294196.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:8180 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932365Ab1EQVne (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 May 2011 17:43:34 -0400
In-Reply-To: <20110517.171412.1017451005914294196.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

gcc 4.5 doesn't like enumerators as flags, and neither does davem.
Replace the enumerated type with macros and a type alias which makes
it clear where the flags are being used.

Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
---
On Tue, 2011-05-17 at 17:14 -0400, David Miller wrote:
> From: Ben Hutchings <bhutchings@solarflare.com>
> Date: Tue, 17 May 2011 22:06:19 +0100
> 
> > But that seems to result in discarding all type information for the
> > flags. I would prefer to improve type checking.
> 
> That's why I don't want a solution like your cast patch, as that
> takes the typing information away.
> 
> Accept that the compiler currently doesn't want to allow enums to be
> used as bit-masks, don't paper around it.
> 
> I'm not applying this patch either, you think all of this "__force"
> casting stuff is better?  No way.

OK, here it is with an ordinary type alias.  I still don't think this is
the right way to go, as neither gcc nor sparse can do any meaningful
type-checking on it.  The type alias should at least help readers.

Ben.

 drivers/net/sfc/efx.c        |    2 +-
 drivers/net/sfc/efx.h        |    2 +-
 drivers/net/sfc/ethtool.c    |    2 +-
 drivers/net/sfc/mdio_10g.c   |    2 +-
 drivers/net/sfc/mdio_10g.h   |    2 +-
 drivers/net/sfc/net_driver.h |   15 +++++++--------
 6 files changed, 12 insertions(+), 13 deletions(-)

diff --git a/drivers/net/sfc/efx.c b/drivers/net/sfc/efx.c
index 05502b3..f840879 100644
--- a/drivers/net/sfc/efx.c
+++ b/drivers/net/sfc/efx.c
@@ -833,7 +833,7 @@ void efx_link_set_advertising(struct efx_nic *efx, u32 advertising)
 	}
 }
 
-void efx_link_set_wanted_fc(struct efx_nic *efx, enum efx_fc_type wanted_fc)
+void efx_link_set_wanted_fc(struct efx_nic *efx, efx_fc_mode wanted_fc)
 {
 	efx->wanted_fc = wanted_fc;
 	if (efx->link_advertising) {
diff --git a/drivers/net/sfc/efx.h b/drivers/net/sfc/efx.h
index 3d83a1f..242d68b 100644
--- a/drivers/net/sfc/efx.h
+++ b/drivers/net/sfc/efx.h
@@ -142,6 +142,6 @@ static inline void efx_schedule_channel(struct efx_channel *channel)
 
 extern void efx_link_status_changed(struct efx_nic *efx);
 extern void efx_link_set_advertising(struct efx_nic *efx, u32);
-extern void efx_link_set_wanted_fc(struct efx_nic *efx, enum efx_fc_type);
+extern void efx_link_set_wanted_fc(struct efx_nic *efx, efx_fc_mode);
 
 #endif /* EFX_EFX_H */
diff --git a/drivers/net/sfc/ethtool.c b/drivers/net/sfc/ethtool.c
index 348437a..114829d 100644
--- a/drivers/net/sfc/ethtool.c
+++ b/drivers/net/sfc/ethtool.c
@@ -698,7 +698,7 @@ static int efx_ethtool_set_pauseparam(struct net_device *net_dev,
 				      struct ethtool_pauseparam *pause)
 {
 	struct efx_nic *efx = netdev_priv(net_dev);
-	enum efx_fc_type wanted_fc, old_fc;
+	efx_fc_mode wanted_fc, old_fc;
 	u32 old_adv;
 	bool reset;
 	int rc = 0;
diff --git a/drivers/net/sfc/mdio_10g.c b/drivers/net/sfc/mdio_10g.c
index 7115914..1e748cf 100644
--- a/drivers/net/sfc/mdio_10g.c
+++ b/drivers/net/sfc/mdio_10g.c
@@ -284,7 +284,7 @@ void efx_mdio_an_reconfigure(struct efx_nic *efx)
 	efx_mdio_write(efx, MDIO_MMD_AN, MDIO_CTRL1, reg);
 }
 
-enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx)
+efx_fc_mode efx_mdio_get_pause(struct efx_nic *efx)
 {
 	BUILD_BUG_ON(EFX_FC_AUTO & (EFX_FC_RX | EFX_FC_TX));
 
diff --git a/drivers/net/sfc/mdio_10g.h b/drivers/net/sfc/mdio_10g.h
index df07039..1616b13 100644
--- a/drivers/net/sfc/mdio_10g.h
+++ b/drivers/net/sfc/mdio_10g.h
@@ -92,7 +92,7 @@ extern void efx_mdio_an_reconfigure(struct efx_nic *efx);
 /* Get pause parameters from AN if available (otherwise return
  * requested pause parameters)
  */
-enum efx_fc_type efx_mdio_get_pause(struct efx_nic *efx);
+extern efx_fc_mode efx_mdio_get_pause(struct efx_nic *efx);
 
 /* Wait for specified MMDs to exit reset within a timeout */
 extern int efx_mdio_wait_reset_mmds(struct efx_nic *efx,
diff --git a/drivers/net/sfc/net_driver.h b/drivers/net/sfc/net_driver.h
index ce9697b..a5aeba8 100644
--- a/drivers/net/sfc/net_driver.h
+++ b/drivers/net/sfc/net_driver.h
@@ -448,12 +448,11 @@ enum nic_state {
 /* Forward declaration */
 struct efx_nic;
 
-/* Pseudo bit-mask flow control field */
-enum efx_fc_type {
-	EFX_FC_RX = FLOW_CTRL_RX,
-	EFX_FC_TX = FLOW_CTRL_TX,
-	EFX_FC_AUTO = 4,
-};
+/* Flow control flags */
+typedef unsigned int efx_fc_mode;
+#define EFX_FC_RX	FLOW_CTRL_RX
+#define EFX_FC_TX	FLOW_CTRL_TX
+#define EFX_FC_AUTO	4
 
 /**
  * struct efx_link_state - Current state of the link
@@ -465,7 +464,7 @@ enum efx_fc_type {
 struct efx_link_state {
 	bool up;
 	bool fd;
-	enum efx_fc_type fc;
+	efx_fc_mode fc;
 	unsigned int speed;
 };
 
@@ -784,7 +783,7 @@ struct efx_nic {
 
 	bool promiscuous;
 	union efx_multicast_hash multicast_hash;
-	enum efx_fc_type wanted_fc;
+	efx_fc_mode wanted_fc;
 
 	atomic_t rx_reset;
 	enum efx_loopback_mode loopback_mode;
-- 
1.7.4

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

