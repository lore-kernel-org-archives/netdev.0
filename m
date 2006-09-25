From: "John W. Linville" <linville@tuxdriver.com>
Subject: Please pull 'upstream' branch of wireless-2.6.git
Date: Mon, 25 Sep 2006 17:50:43 -0400
Message-ID: <20060925215037.GG16949@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:27663 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1751475AbWIYVwN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 25 Sep 2006 17:52:13 -0400
To: jeff@garzik.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The following changes since commit 7c250413e5b7c3dfae89354725b70c76d7621395:
  Al Viro:
        pata_pdc2027x iomem annotations

are found in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-2.6.git upstream

Daniel Drake:
      WE-21 for zd1211rw
      softmac: Update MAINTAINERS entry

Jean Tourrilhes:
      WE-21 for airo
      WE-21 for atmel
      WE-21 for hostap
      WE-21 for ipw2100
      WE-21 for orinoco
      WE-21 for Prism54
      WE-21 for ray_cs
      WE-21 for wl3501
      WE-21 for zd1201
      WE-21 for ipw2200

John W. Linville:
      WE-21 support (core API)

Larry Finger:
      bcm43xx: WE-21 support
      bcm43xx-softmac: update PHY initialization
      bcm43xx-softmac: update noise handling
      bcm43xx-softmac: improve wrong firmware message
      bcm43xx: fix netdev watchdog timeouts

Ulrich Kunitz:
      zd1211rw: 16-bit writes for physical control registers
      zd1211rw: Removes wrong assertions
      zd1211rw: Added workqueue
      zd1211rw: Add LED support

 MAINTAINERS                                 |    1 
 drivers/net/wireless/airo.c                 |   19 ++--
 drivers/net/wireless/atmel.c                |   18 ++--
 drivers/net/wireless/bcm43xx/bcm43xx.h      |    1 
 drivers/net/wireless/bcm43xx/bcm43xx_main.c |   10 +-
 drivers/net/wireless/bcm43xx/bcm43xx_phy.c  |   15 +--
 drivers/net/wireless/bcm43xx/bcm43xx_wx.c   |    2 
 drivers/net/wireless/bcm43xx/bcm43xx_xmit.c |    5 -
 drivers/net/wireless/hostap/hostap_ioctl.c  |   10 +-
 drivers/net/wireless/ipw2100.c              |   14 +--
 drivers/net/wireless/ipw2200.c              |   16 +--
 drivers/net/wireless/orinoco.c              |   10 +-
 drivers/net/wireless/prism54/isl_ioctl.c    |   16 ++-
 drivers/net/wireless/ray_cs.c               |    2 
 drivers/net/wireless/wl3501_cs.c            |    6 +
 drivers/net/wireless/zd1201.c               |    2 
 drivers/net/wireless/zd1211rw/zd_chip.c     |  137 +++++++++++----------------
 drivers/net/wireless/zd1211rw/zd_chip.h     |   23 +++--
 drivers/net/wireless/zd1211rw/zd_mac.c      |   50 ++++++++++
 drivers/net/wireless/zd1211rw/zd_mac.h      |    5 +
 drivers/net/wireless/zd1211rw/zd_netdev.c   |    2 
 drivers/net/wireless/zd1211rw/zd_usb.c      |   10 ++
 drivers/net/wireless/zd1211rw/zd_usb.h      |    2 
 include/linux/netdevice.h                   |    1 
 include/linux/wireless.h                    |   24 ++++-
 net/core/net-sysfs.c                        |    5 -
 net/core/wireless.c                         |   67 ++++++++-----
 net/ieee80211/softmac/ieee80211softmac_wx.c |    8 +-
 28 files changed, 274 insertions(+), 207 deletions(-)

diff --git a/MAINTAINERS b/MAINTAINERS
index 16af51b..bd446e2 100644
--- a/MAINTAINERS
+++ b/MAINTAINERS
@@ -2655,7 +2655,6 @@ M:	josejx@gentoo.org
 P:	Daniel Drake
 M:	dsd@gentoo.org
 W:	http://softmac.sipsolutions.net/
-L:	softmac-dev@sipsolutions.net
 L:	netdev@vger.kernel.org
 S:	Maintained
 
diff --git a/drivers/net/wireless/airo.c b/drivers/net/wireless/airo.c
index bff04cb..ba737c6 100644
--- a/drivers/net/wireless/airo.c
+++ b/drivers/net/wireless/airo.c
@@ -5868,7 +5868,7 @@ static int airo_set_essid(struct net_dev
 		int	index = (dwrq->flags & IW_ENCODE_INDEX) - 1;
 
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE+1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG ;
 		}
 		/* Check if index is valid */
@@ -5880,7 +5880,7 @@ static int airo_set_essid(struct net_dev
 		memset(SSID_rid.ssids[index].ssid, 0,
 		       sizeof(SSID_rid.ssids[index].ssid));
 		memcpy(SSID_rid.ssids[index].ssid, extra, dwrq->length);
-		SSID_rid.ssids[index].len = dwrq->length - 1;
+		SSID_rid.ssids[index].len = dwrq->length;
 	}
 	SSID_rid.len = sizeof(SSID_rid);
 	/* Write it to the card */
@@ -5990,7 +5990,7 @@ static int airo_set_nick(struct net_devi
 	struct airo_info *local = dev->priv;
 
 	/* Check the size of the string */
-	if(dwrq->length > 16 + 1) {
+	if(dwrq->length > 16) {
 		return -E2BIG;
 	}
 	readConfigRid(local, 1);
@@ -6015,7 +6015,7 @@ static int airo_get_nick(struct net_devi
 	readConfigRid(local, 1);
 	strncpy(extra, local->config.nodeName, 16);
 	extra[16] = '\0';
-	dwrq->length = strlen(extra) + 1;
+	dwrq->length = strlen(extra);
 
 	return 0;
 }
@@ -6767,9 +6767,9 @@ static int airo_set_retry(struct net_dev
 	}
 	readConfigRid(local, 1);
 	if(vwrq->flags & IW_RETRY_LIMIT) {
-		if(vwrq->flags & IW_RETRY_MAX)
+		if(vwrq->flags & IW_RETRY_LONG)
 			local->config.longRetryLimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			local->config.shortRetryLimit = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -6805,14 +6805,14 @@ static int airo_get_retry(struct net_dev
 	if((vwrq->flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME) {
 		vwrq->flags = IW_RETRY_LIFETIME;
 		vwrq->value = (int)local->config.txLifetime * 1024;
-	} else if((vwrq->flags & IW_RETRY_MAX)) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	} else if((vwrq->flags & IW_RETRY_LONG)) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = (int)local->config.longRetryLimit;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = (int)local->config.shortRetryLimit;
 		if((int)local->config.shortRetryLimit != (int)local->config.longRetryLimit)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
@@ -6990,6 +6990,7 @@ static int airo_set_power(struct net_dev
 			local->config.rmode |= RXMODE_BC_MC_ADDR;
 			set_bit (FLAG_COMMIT, &local->flags);
 		case IW_POWER_ON:
+			/* This is broken, fixme ;-) */
 			break;
 		default:
 			return -EINVAL;
diff --git a/drivers/net/wireless/atmel.c b/drivers/net/wireless/atmel.c
index 995c7be..0fc267d 100644
--- a/drivers/net/wireless/atmel.c
+++ b/drivers/net/wireless/atmel.c
@@ -1656,13 +1656,13 @@ static int atmel_set_essid(struct net_de
 		priv->connect_to_any_BSS = 0;
 
 		/* Check the size of the string */
-		if (dwrq->length > MAX_SSID_LENGTH + 1)
+		if (dwrq->length > MAX_SSID_LENGTH)
 			 return -E2BIG;
 		if (index != 0)
 			return -EINVAL;
 
-		memcpy(priv->new_SSID, extra, dwrq->length - 1);
-		priv->new_SSID_size = dwrq->length - 1;
+		memcpy(priv->new_SSID, extra, dwrq->length);
+		priv->new_SSID_size = dwrq->length;
 	}
 
 	return -EINPROGRESS;
@@ -2120,9 +2120,9 @@ static int atmel_set_retry(struct net_de
 	struct atmel_private *priv = netdev_priv(dev);
 
 	if (!vwrq->disabled && (vwrq->flags & IW_RETRY_LIMIT)) {
-		if (vwrq->flags & IW_RETRY_MAX)
+		if (vwrq->flags & IW_RETRY_LONG)
 			priv->long_retry = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MIN)
+		else if (vwrq->flags & IW_RETRY_SHORT)
 			priv->short_retry = vwrq->value;
 		else {
 			/* No modifier : set both */
@@ -2144,15 +2144,15 @@ static int atmel_get_retry(struct net_de
 
 	vwrq->disabled = 0;      /* Can't be disabled */
 
-	/* Note : by default, display the min retry number */
-	if (vwrq->flags & IW_RETRY_MAX) {
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	/* Note : by default, display the short retry number */
+	if (vwrq->flags & IW_RETRY_LONG) {
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		vwrq->value = priv->long_retry;
 	} else {
 		vwrq->flags = IW_RETRY_LIMIT;
 		vwrq->value = priv->short_retry;
 		if (priv->long_retry != priv->short_retry)
-			vwrq->flags |= IW_RETRY_MIN;
+			vwrq->flags |= IW_RETRY_SHORT;
 	}
 
 	return 0;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx.h b/drivers/net/wireless/bcm43xx/bcm43xx.h
index 6d4ea36..d6a8bf0 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx.h
+++ b/drivers/net/wireless/bcm43xx/bcm43xx.h
@@ -666,7 +666,6 @@ struct bcm43xx_noise_calculation {
 };
 
 struct bcm43xx_stats {
-	u8 link_quality;
 	u8 noise;
 	struct iw_statistics wstats;
 	/* Store the last TX/RX times here for updating the leds. */
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_main.c b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
index cb9a3ae..eb65db7 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_main.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_main.c
@@ -2405,9 +2405,10 @@ static int bcm43xx_chip_init(struct bcm4
 				   BCM43xx_UCODE_TIME) & 0x1f);
 
 	if ( value16 > 0x128 ) {
-		dprintk(KERN_ERR PFX
-			"Firmware: no support for microcode rev > 0x128\n");
-		err = -1;
+		printk(KERN_ERR PFX
+			"Firmware: no support for microcode extracted "
+			"from version 4.x binary drivers.\n");
+		err = -EOPNOTSUPP;
 		goto err_release_fw;
 	}
 
@@ -3169,8 +3170,7 @@ static void bcm43xx_periodic_work_handle
 		 * be preemtible.
 		 */
 		mutex_lock(&bcm->mutex);
-		netif_stop_queue(bcm->net_dev);
-		synchronize_net();
+		netif_tx_disable(bcm->net_dev);
 		spin_lock_irqsave(&bcm->irq_lock, flags);
 		bcm43xx_mac_suspend(bcm);
 		if (bcm43xx_using_pio(bcm))
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
index eafd0f6..52ce2a9 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_phy.c
@@ -361,7 +361,7 @@ static void bcm43xx_phy_setupg(struct bc
 	if (phy->rev <= 2)
 		for (i = 0; i < BCM43xx_ILT_NOISESCALEG_SIZE; i++)
 			bcm43xx_ilt_write(bcm, 0x1400 + i, bcm43xx_ilt_noisescaleg1[i]);
-	else if ((phy->rev == 7) && (bcm43xx_phy_read(bcm, 0x0449) & 0x0200))
+	else if ((phy->rev >= 7) && (bcm43xx_phy_read(bcm, 0x0449) & 0x0200))
 		for (i = 0; i < BCM43xx_ILT_NOISESCALEG_SIZE; i++)
 			bcm43xx_ilt_write(bcm, 0x1400 + i, bcm43xx_ilt_noisescaleg3[i]);
 	else
@@ -371,7 +371,7 @@ static void bcm43xx_phy_setupg(struct bc
 	if (phy->rev == 2)
 		for (i = 0; i < BCM43xx_ILT_SIGMASQR_SIZE; i++)
 			bcm43xx_ilt_write(bcm, 0x5000 + i, bcm43xx_ilt_sigmasqr1[i]);
-	else if ((phy->rev > 2) && (phy->rev <= 7))
+	else if ((phy->rev > 2) && (phy->rev <= 8))
 		for (i = 0; i < BCM43xx_ILT_SIGMASQR_SIZE; i++)
 			bcm43xx_ilt_write(bcm, 0x5000 + i, bcm43xx_ilt_sigmasqr2[i]);
 	
@@ -1197,7 +1197,7 @@ static void bcm43xx_phy_initg(struct bcm
 
 	if (phy->rev == 1)
 		bcm43xx_phy_initb5(bcm);
-	else if (phy->rev >= 2 && phy->rev <= 7)
+	else
 		bcm43xx_phy_initb6(bcm);
 	if (phy->rev >= 2 || phy->connected)
 		bcm43xx_phy_inita(bcm);
@@ -1241,23 +1241,22 @@ static void bcm43xx_phy_initg(struct bcm
 		bcm43xx_phy_lo_g_measure(bcm);
 	} else {
 		if (radio->version == 0x2050 && radio->revision == 8) {
-			//FIXME
+			bcm43xx_radio_write16(bcm, 0x0052,
+					      (radio->txctl1 << 4) | radio->txctl2);
 		} else {
 			bcm43xx_radio_write16(bcm, 0x0052,
 					      (bcm43xx_radio_read16(bcm, 0x0052)
 					       & 0xFFF0) | radio->txctl1);
 		}
 		if (phy->rev >= 6) {
-			/*
 			bcm43xx_phy_write(bcm, 0x0036,
 					  (bcm43xx_phy_read(bcm, 0x0036)
-					   & 0xF000) | (FIXME << 12));
-			*/
+					   & 0xF000) | (radio->txctl2 << 12));
 		}
 		if (bcm->sprom.boardflags & BCM43xx_BFL_PACTRL)
 			bcm43xx_phy_write(bcm, 0x002E, 0x8075);
 		else
-			bcm43xx_phy_write(bcm, 0x003E, 0x807F);
+			bcm43xx_phy_write(bcm, 0x002E, 0x807F);
 		if (phy->rev < 2)
 			bcm43xx_phy_write(bcm, 0x002F, 0x0101);
 		else
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
index 888077f..9b7b15c 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_wx.c
@@ -334,7 +334,7 @@ static int bcm43xx_wx_get_nick(struct ne
 	size_t len;
 
 	mutex_lock(&bcm->mutex);
-	len = strlen(bcm->nick) + 1;
+	len = strlen(bcm->nick);
 	memcpy(extra, bcm->nick, len);
 	data->data.length = (__u16)len;
 	data->data.flags = 1;
diff --git a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
index c0efbfe..0159e4e 100644
--- a/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
+++ b/drivers/net/wireless/bcm43xx/bcm43xx_xmit.c
@@ -496,15 +496,14 @@ int bcm43xx_rx(struct bcm43xx_private *b
 	stats.signal = bcm43xx_rssi_postprocess(bcm, rxhdr->rssi, is_ofdm,
 					      !!(rxflags1 & BCM43xx_RXHDR_FLAGS1_2053RSSIADJ),
 					      !!(rxflags3 & BCM43xx_RXHDR_FLAGS3_2050RSSIADJ));
-//TODO	stats.noise = 
+	stats.noise = bcm->stats.noise;
 	if (is_ofdm)
 		stats.rate = bcm43xx_plcp_get_bitrate_ofdm(plcp);
 	else
 		stats.rate = bcm43xx_plcp_get_bitrate_cck(plcp);
 	stats.received_channel = radio->channel;
-//TODO	stats.control = 
 	stats.mask = IEEE80211_STATMASK_SIGNAL |
-//TODO		     IEEE80211_STATMASK_NOISE |
+		     IEEE80211_STATMASK_NOISE |
 		     IEEE80211_STATMASK_RATE |
 		     IEEE80211_STATMASK_RSSI;
 	if (phy->type == BCM43xx_PHYTYPE_A)
diff --git a/drivers/net/wireless/hostap/hostap_ioctl.c b/drivers/net/wireless/hostap/hostap_ioctl.c
index 7a49785..d061fb3 100644
--- a/drivers/net/wireless/hostap/hostap_ioctl.c
+++ b/drivers/net/wireless/hostap/hostap_ioctl.c
@@ -1412,9 +1412,9 @@ #if 0
 	/* what could be done, if firmware would support this.. */
 
 	if (rrq->flags & IW_RETRY_LIMIT) {
-		if (rrq->flags & IW_RETRY_MAX)
+		if (rrq->flags & IW_RETRY_LONG)
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
-		else if (rrq->flags & IW_RETRY_MIN)
+		else if (rrq->flags & IW_RETRY_SHORT)
 			HFA384X_RID_SHORTRETRYLIMIT = rrq->value;
 		else {
 			HFA384X_RID_LONGRETRYLIMIT = rrq->value;
@@ -1468,14 +1468,14 @@ static int prism2_ioctl_giwretry(struct 
 				rrq->value = le16_to_cpu(altretry);
 			else
 				rrq->value = local->manual_retry_count;
-		} else if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		} else if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = longretry;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = shortretry;
 			if (shortretry != longretry)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 	return 0;
diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
index b4d81a0..6c5add7 100644
--- a/drivers/net/wireless/ipw2100.c
+++ b/drivers/net/wireless/ipw2100.c
@@ -6958,7 +6958,7 @@ static int ipw2100_wx_set_essid(struct n
 	}
 
 	if (wrqu->essid.flags && wrqu->essid.length) {
-		length = wrqu->essid.length - 1;
+		length = wrqu->essid.length;
 		essid = extra;
 	}
 
@@ -7051,7 +7051,7 @@ static int ipw2100_wx_get_nick(struct ne
 
 	struct ipw2100_priv *priv = ieee80211_priv(dev);
 
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 
@@ -7343,14 +7343,14 @@ static int ipw2100_wx_set_retry(struct n
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MIN) {
+	if (wrqu->retry.flags & IW_RETRY_SHORT) {
 		err = ipw2100_set_short_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Short Retry Limit -> %d \n",
 			     wrqu->retry.value);
 		goto done;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
 		err = ipw2100_set_long_retry(priv, wrqu->retry.value);
 		IPW_DEBUG_WX("SET Long Retry Limit -> %d \n",
 			     wrqu->retry.value);
@@ -7383,14 +7383,14 @@ static int ipw2100_wx_get_retry(struct n
 	if ((wrqu->retry.flags & IW_RETRY_TYPE) == IW_RETRY_LIFETIME)
 		return -EINVAL;
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
 	} else {
 		wrqu->retry.flags =
 		    (priv->short_retry_limit !=
 		     priv->long_retry_limit) ?
-		    IW_RETRY_LIMIT | IW_RETRY_MIN : IW_RETRY_LIMIT;
+		    IW_RETRY_LIMIT | IW_RETRY_SHORT : IW_RETRY_LIMIT;
 
 		wrqu->retry.value = priv->short_retry_limit;
 	}
diff --git a/drivers/net/wireless/ipw2200.c b/drivers/net/wireless/ipw2200.c
index 7358664..5685d7b 100644
--- a/drivers/net/wireless/ipw2200.c
+++ b/drivers/net/wireless/ipw2200.c
@@ -8875,8 +8875,6 @@ static int ipw_wx_set_essid(struct net_d
         }
 
 	length = min((int)wrqu->essid.length, IW_ESSID_MAX_SIZE);
-	if (!extra[length - 1])
-		length--;
 
 	priv->config |= CFG_STATIC_ESSID;
 
@@ -8953,7 +8951,7 @@ static int ipw_wx_get_nick(struct net_de
 	struct ipw_priv *priv = ieee80211_priv(dev);
 	IPW_DEBUG_WX("Getting nick\n");
 	mutex_lock(&priv->mutex);
-	wrqu->data.length = strlen(priv->nick) + 1;
+	wrqu->data.length = strlen(priv->nick);
 	memcpy(extra, priv->nick, wrqu->data.length);
 	wrqu->data.flags = 1;	/* active */
 	mutex_unlock(&priv->mutex);
@@ -9276,9 +9274,9 @@ static int ipw_wx_set_retry(struct net_d
 		return -EINVAL;
 
 	mutex_lock(&priv->mutex);
-	if (wrqu->retry.flags & IW_RETRY_MIN)
+	if (wrqu->retry.flags & IW_RETRY_SHORT)
 		priv->short_retry_limit = (u8) wrqu->retry.value;
-	else if (wrqu->retry.flags & IW_RETRY_MAX)
+	else if (wrqu->retry.flags & IW_RETRY_LONG)
 		priv->long_retry_limit = (u8) wrqu->retry.value;
 	else {
 		priv->short_retry_limit = (u8) wrqu->retry.value;
@@ -9307,11 +9305,11 @@ static int ipw_wx_get_retry(struct net_d
 		return -EINVAL;
 	}
 
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		wrqu->retry.value = priv->long_retry_limit;
-	} else if (wrqu->retry.flags & IW_RETRY_MIN) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	} else if (wrqu->retry.flags & IW_RETRY_SHORT) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 		wrqu->retry.value = priv->short_retry_limit;
 	} else {
 		wrqu->retry.flags = IW_RETRY_LIMIT;
diff --git a/drivers/net/wireless/orinoco.c b/drivers/net/wireless/orinoco.c
index 1840b69..9e19a96 100644
--- a/drivers/net/wireless/orinoco.c
+++ b/drivers/net/wireless/orinoco.c
@@ -3037,7 +3037,7 @@ static int orinoco_ioctl_getessid(struct
 	}
 
 	erq->flags = 1;
-	erq->length = strlen(essidbuf) + 1;
+	erq->length = strlen(essidbuf);
 
 	return 0;
 }
@@ -3078,7 +3078,7 @@ static int orinoco_ioctl_getnick(struct 
 	memcpy(nickbuf, priv->nick, IW_ESSID_MAX_SIZE+1);
 	orinoco_unlock(priv, &flags);
 
-	nrq->length = strlen(nickbuf)+1;
+	nrq->length = strlen(nickbuf);
 
 	return 0;
 }
@@ -3575,14 +3575,14 @@ static int orinoco_ioctl_getretry(struct
 		rrq->value = lifetime * 1000;	/* ??? */
 	} else {
 		/* By default, display the min number */
-		if ((rrq->flags & IW_RETRY_MAX)) {
-			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		if ((rrq->flags & IW_RETRY_LONG)) {
+			rrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 			rrq->value = long_limit;
 		} else {
 			rrq->flags = IW_RETRY_LIMIT;
 			rrq->value = short_limit;
 			if(short_limit != long_limit)
-				rrq->flags |= IW_RETRY_MIN;
+				rrq->flags |= IW_RETRY_SHORT;
 		}
 	}
 
diff --git a/drivers/net/wireless/prism54/isl_ioctl.c b/drivers/net/wireless/prism54/isl_ioctl.c
index c09fbf7..286325c 100644
--- a/drivers/net/wireless/prism54/isl_ioctl.c
+++ b/drivers/net/wireless/prism54/isl_ioctl.c
@@ -742,9 +742,9 @@ prism54_set_essid(struct net_device *nde
 
 	/* Check if we were asked for `any' */
 	if (dwrq->flags && dwrq->length) {
-		if (dwrq->length > min(33, IW_ESSID_MAX_SIZE + 1))
+		if (dwrq->length > 32)
 			return -E2BIG;
-		essid.length = dwrq->length - 1;
+		essid.length = dwrq->length;
 		memcpy(essid.octets, extra, dwrq->length);
 	} else
 		essid.length = 0;
@@ -814,7 +814,7 @@ prism54_get_nick(struct net_device *ndev
 	dwrq->length = 0;
 
 	down_read(&priv->mib_sem);
-	dwrq->length = strlen(priv->nickname) + 1;
+	dwrq->length = strlen(priv->nickname);
 	memcpy(extra, priv->nickname, dwrq->length);
 	up_read(&priv->mib_sem);
 
@@ -992,9 +992,9 @@ prism54_set_retry(struct net_device *nde
 		return -EINVAL;
 
 	if (vwrq->flags & IW_RETRY_LIMIT) {
-		if (vwrq->flags & IW_RETRY_MIN)
+		if (vwrq->flags & IW_RETRY_SHORT)
 			slimit = vwrq->value;
-		else if (vwrq->flags & IW_RETRY_MAX)
+		else if (vwrq->flags & IW_RETRY_LONG)
 			llimit = vwrq->value;
 		else {
 			/* we are asked to set both */
@@ -1035,18 +1035,18 @@ prism54_get_retry(struct net_device *nde
 		    mgt_get_request(priv, DOT11_OID_MAXTXLIFETIME, 0, NULL, &r);
 		vwrq->value = r.u * 1024;
 		vwrq->flags = IW_RETRY_LIFETIME;
-	} else if ((vwrq->flags & IW_RETRY_MAX)) {
+	} else if ((vwrq->flags & IW_RETRY_LONG)) {
 		/* we are asked for the long retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_LONGRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 	} else {
 		/* default. get the  short retry limit */
 		rvalue |=
 		    mgt_get_request(priv, DOT11_OID_SHORTRETRIES, 0, NULL, &r);
 		vwrq->value = r.u;
-		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+		vwrq->flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 	}
 
 	return rvalue;
diff --git a/drivers/net/wireless/ray_cs.c b/drivers/net/wireless/ray_cs.c
index 4574290..e82548e 100644
--- a/drivers/net/wireless/ray_cs.c
+++ b/drivers/net/wireless/ray_cs.c
@@ -1173,7 +1173,7 @@ static int ray_set_essid(struct net_devi
 		return -EOPNOTSUPP;
 	} else {
 		/* Check the size of the string */
-		if(dwrq->length > IW_ESSID_MAX_SIZE + 1) {
+		if(dwrq->length > IW_ESSID_MAX_SIZE) {
 			return -E2BIG;
 		}
 
diff --git a/drivers/net/wireless/wl3501_cs.c b/drivers/net/wireless/wl3501_cs.c
index e0d294c..e3ae5f6 100644
--- a/drivers/net/wireless/wl3501_cs.c
+++ b/drivers/net/wireless/wl3501_cs.c
@@ -1802,15 +1802,15 @@ static int wl3501_get_retry(struct net_d
 				      &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	if (wrqu->retry.flags & IW_RETRY_MAX) {
-		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MAX;
+	if (wrqu->retry.flags & IW_RETRY_LONG) {
+		wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_LONG;
 		goto set_value;
 	}
 	rc = wl3501_get_mib_value(this, WL3501_MIB_ATTR_SHORT_RETRY_LIMIT,
 				  &retry, sizeof(retry));
 	if (rc)
 		goto out;
-	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_MIN;
+	wrqu->retry.flags = IW_RETRY_LIMIT | IW_RETRY_SHORT;
 set_value:
 	wrqu->retry.value = retry;
 	wrqu->retry.disabled = 0;
diff --git a/drivers/net/wireless/zd1201.c b/drivers/net/wireless/zd1201.c
index c52e9bc..a44dda9 100644
--- a/drivers/net/wireless/zd1201.c
+++ b/drivers/net/wireless/zd1201.c
@@ -1218,7 +1218,7 @@ static int zd1201_set_essid(struct net_d
 		return -EINVAL;
 	if (data->length < 1)
 		data->length = 1;
-	zd->essidlen = data->length-1;
+	zd->essidlen = data->length;
 	memset(zd->essid, 0, IW_ESSID_MAX_SIZE+1);
 	memcpy(zd->essid, essid, data->length);
 	return zd1201_join(zd, zd->essid, zd->essidlen);
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.c b/drivers/net/wireless/zd1211rw/zd_chip.c
index 7c4e32c..aa661b2 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.c
+++ b/drivers/net/wireless/zd1211rw/zd_chip.c
@@ -249,7 +249,6 @@ int zd_ioread16(struct zd_chip *chip, zd
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread16_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -260,7 +259,6 @@ int zd_ioread32(struct zd_chip *chip, zd
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread32_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -271,7 +269,6 @@ int zd_iowrite16(struct zd_chip *chip, z
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite16_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -282,7 +279,6 @@ int zd_iowrite32(struct zd_chip *chip, z
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32_locked(chip, value, addr);
 	mutex_unlock(&chip->mutex);
@@ -294,7 +290,6 @@ int zd_ioread32v(struct zd_chip *chip, c
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_ioread32v_locked(chip, values, addresses, count);
 	mutex_unlock(&chip->mutex);
@@ -306,7 +301,6 @@ int zd_iowrite32a(struct zd_chip *chip, 
 {
 	int r;
 
-	ZD_ASSERT(!mutex_is_locked(&chip->mutex));
 	mutex_lock(&chip->mutex);
 	r = zd_iowrite32a_locked(chip, ioreqs, count);
 	mutex_unlock(&chip->mutex);
@@ -331,13 +325,22 @@ static int read_pod(struct zd_chip *chip
 	chip->patch_cr157 = (value >> 13) & 0x1;
 	chip->patch_6m_band_edge = (value >> 21) & 0x1;
 	chip->new_phy_layout = (value >> 31) & 0x1;
+	chip->link_led = ((value >> 4) & 1) ? LED1 : LED2;
+	chip->supports_tx_led = 1;
+	if (value & (1 << 24)) { /* LED scenario */
+		if (value & (1 << 29))
+			chip->supports_tx_led = 0;
+	}
 
 	dev_dbg_f(zd_chip_dev(chip),
 		"RF %s %#01x PA type %#01x patch CCK %d patch CR157 %d "
-		"patch 6M %d new PHY %d\n",
+		"patch 6M %d new PHY %d link LED%d tx led %d\n",
 		zd_rf_name(*rf_type), *rf_type,
 		chip->pa_type, chip->patch_cck_gain,
-		chip->patch_cr157, chip->patch_6m_band_edge, chip->new_phy_layout);
+		chip->patch_cr157, chip->patch_6m_band_edge,
+		chip->new_phy_layout,
+		chip->link_led == LED1 ? 1 : 2,
+		chip->supports_tx_led);
 	return 0;
 error:
 	*rf_type = 0;
@@ -1181,7 +1184,7 @@ static int update_pwr_int(struct zd_chip
 	u8 value = chip->pwr_int_values[channel - 1];
 	dev_dbg_f(zd_chip_dev(chip), "channel %d pwr_int %#04x\n",
 		 channel, value);
-	return zd_iowrite32_locked(chip, value, CR31);
+	return zd_iowrite16_locked(chip, value, CR31);
 }
 
 static int update_pwr_cal(struct zd_chip *chip, u8 channel)
@@ -1189,12 +1192,12 @@ static int update_pwr_cal(struct zd_chip
 	u8 value = chip->pwr_cal_values[channel-1];
 	dev_dbg_f(zd_chip_dev(chip), "channel %d pwr_cal %#04x\n",
 		 channel, value);
-	return zd_iowrite32_locked(chip, value, CR68);
+	return zd_iowrite16_locked(chip, value, CR68);
 }
 
 static int update_ofdm_cal(struct zd_chip *chip, u8 channel)
 {
-	struct zd_ioreq32 ioreqs[3];
+	struct zd_ioreq16 ioreqs[3];
 
 	ioreqs[0].addr = CR67;
 	ioreqs[0].value = chip->ofdm_cal_values[OFDM_36M_INDEX][channel-1];
@@ -1206,7 +1209,7 @@ static int update_ofdm_cal(struct zd_chi
 	dev_dbg_f(zd_chip_dev(chip),
 		"channel %d ofdm_cal 36M %#04x 48M %#04x 54M %#04x\n",
 		channel, ioreqs[0].value, ioreqs[1].value, ioreqs[2].value);
-	return zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+	return zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 }
 
 static int update_channel_integration_and_calibration(struct zd_chip *chip,
@@ -1218,7 +1221,7 @@ static int update_channel_integration_an
 	if (r)
 		return r;
 	if (chip->is_zd1211b) {
-		static const struct zd_ioreq32 ioreqs[] = {
+		static const struct zd_ioreq16 ioreqs[] = {
 			{ CR69, 0x28 },
 			{},
 			{ CR69, 0x2a },
@@ -1230,7 +1233,7 @@ static int update_channel_integration_an
 		r = update_pwr_cal(chip, channel);
 		if (r)
 			return r;
-		r = zd_iowrite32a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+		r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
 		if (r)
 			return r;
 	}
@@ -1252,7 +1255,7 @@ static int patch_cck_gain(struct zd_chip
 	if (r)
 		return r;
 	dev_dbg_f(zd_chip_dev(chip), "patching value %x\n", value & 0xff);
-	return zd_iowrite32_locked(chip, value & 0xff, CR47);
+	return zd_iowrite16_locked(chip, value & 0xff, CR47);
 }
 
 int zd_chip_set_channel(struct zd_chip *chip, u8 channel)
@@ -1295,89 +1298,60 @@ u8 zd_chip_get_channel(struct zd_chip *c
 	return channel;
 }
 
-static u16 led_mask(int led)
+int zd_chip_control_leds(struct zd_chip *chip, enum led_status status)
 {
-	switch (led) {
-	case 1:
-		return LED1;
-	case 2:
-		return LED2;
-	default:
-		return 0;
-	}
-}
-
-static int read_led_reg(struct zd_chip *chip, u16 *status)
-{
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	return zd_ioread16_locked(chip, status, CR_LED);
-}
-
-static int write_led_reg(struct zd_chip *chip, u16 status)
-{
-	ZD_ASSERT(mutex_is_locked(&chip->mutex));
-	return zd_iowrite16_locked(chip, status, CR_LED);
-}
+	static const zd_addr_t a[] = {
+		FW_LINK_STATUS,
+		CR_LED,
+	};
 
-int zd_chip_led_status(struct zd_chip *chip, int led, enum led_status status)
-{
-	int r, ret;
-	u16 mask = led_mask(led);
-	u16 reg;
+	int r;
+	u16 v[ARRAY_SIZE(a)];
+	struct zd_ioreq16 ioreqs[ARRAY_SIZE(a)] = {
+		[0] = { FW_LINK_STATUS },
+		[1] = { CR_LED },
+	};
+	u16 other_led;
 
-	if (!mask)
-		return -EINVAL;
 	mutex_lock(&chip->mutex);
-	r = read_led_reg(chip, &reg);
+	r = zd_ioread16v_locked(chip, v, (const zd_addr_t *)a, ARRAY_SIZE(a));
 	if (r)
-		return r;
+		goto out;
+
+	other_led = chip->link_led == LED1 ? LED2 : LED1;
+
 	switch (status) {
-	case LED_STATUS:
-		return (reg & mask) ? LED_ON : LED_OFF;
 	case LED_OFF:
-		reg &= ~mask;
-		ret = LED_OFF;
+		ioreqs[0].value = FW_LINK_OFF;
+		ioreqs[1].value = v[1] & ~(LED1|LED2);
 		break;
-	case LED_FLIP:
-		reg ^= mask;
-		ret = (reg&mask) ? LED_ON : LED_OFF;
+	case LED_SCANNING:
+		ioreqs[0].value = FW_LINK_OFF;
+		ioreqs[1].value = v[1] & ~other_led;
+		if (get_seconds() % 3 == 0) {
+			ioreqs[1].value &= ~chip->link_led;
+		} else {
+			ioreqs[1].value |= chip->link_led;
+		}
 		break;
-	case LED_ON:
-		reg |= mask;
-		ret = LED_ON;
+	case LED_ASSOCIATED:
+		ioreqs[0].value = FW_LINK_TX;
+		ioreqs[1].value = v[1] & ~other_led;
+		ioreqs[1].value |= chip->link_led;
 		break;
 	default:
-		return -EINVAL;
-	}
-	r = write_led_reg(chip, reg);
-	if (r) {
-		ret = r;
+		r = -EINVAL;
 		goto out;
 	}
-out:
-	mutex_unlock(&chip->mutex);
-	return r;
-}
-
-int zd_chip_led_flip(struct zd_chip *chip, int led,
-	const unsigned int *phases_msecs, unsigned int count)
-{
-	int i, r;
-	enum led_status status;
 
-	r = zd_chip_led_status(chip, led, LED_STATUS);
-	if (r)
-		return r;
-	status = r;
-	for (i = 0; i < count; i++) {
-		r = zd_chip_led_status(chip, led, LED_FLIP);
-		if (r < 0)
+	if (v[0] != ioreqs[0].value || v[1] != ioreqs[1].value) {
+		r = zd_iowrite16a_locked(chip, ioreqs, ARRAY_SIZE(ioreqs));
+		if (r)
 			goto out;
-		msleep(phases_msecs[i]);
 	}
-
+	r = 0;
 out:
-	zd_chip_led_status(chip, led, status);
+	mutex_unlock(&chip->mutex);
 	return r;
 }
 
@@ -1679,4 +1653,3 @@ int zd_rfwritev_cr_locked(struct zd_chip
 
 	return 0;
 }
-
diff --git a/drivers/net/wireless/zd1211rw/zd_chip.h b/drivers/net/wireless/zd1211rw/zd_chip.h
index 4b12508..ae59597 100644
--- a/drivers/net/wireless/zd1211rw/zd_chip.h
+++ b/drivers/net/wireless/zd1211rw/zd_chip.h
@@ -428,6 +428,7 @@ #define CR_LED				CTL_REG(0x0644)
 /* masks for controlling LEDs */
 #define LED1				0x0100
 #define LED2				0x0200
+#define LED_SW				0x0400
 
 /* Seems to indicate that the configuration is over.
  */
@@ -629,6 +630,10 @@ #define FW_LINK_STATUS          FW_REG(3
 #define FW_SOFT_RESET           FW_REG(4)
 #define FW_FLASH_CHK            FW_REG(5)
 
+#define FW_LINK_OFF		0x0
+#define FW_LINK_TX		0x1
+/* 0x2 - link led on? */
+
 enum {
 	CR_BASE_OFFSET			= 0x9000,
 	FW_START_OFFSET			= 0xee00,
@@ -663,8 +668,11 @@ struct zd_chip {
 	u8 pwr_int_values[E2P_CHANNEL_COUNT];
 	/* SetPointOFDM in the vendor driver */
 	u8 ofdm_cal_values[3][E2P_CHANNEL_COUNT];
-	u8 pa_type:4, patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
-	   new_phy_layout:1, is_zd1211b:1;
+	u16 link_led;
+	unsigned int pa_type:4,
+		patch_cck_gain:1, patch_cr157:1, patch_6m_band_edge:1,
+		new_phy_layout:1,
+		is_zd1211b:1, supports_tx_led:1;
 };
 
 static inline struct zd_chip *zd_usb_to_chip(struct zd_usb *usb)
@@ -812,15 +820,12 @@ int zd_chip_lock_phy_regs(struct zd_chip
 int zd_chip_unlock_phy_regs(struct zd_chip *chip);
 
 enum led_status {
-	LED_OFF	   = 0,
-	LED_ON     = 1,
-	LED_FLIP   = 2,
-	LED_STATUS = 3,
+	LED_OFF = 0,
+	LED_SCANNING = 1,
+	LED_ASSOCIATED = 2,
 };
 
-int zd_chip_led_status(struct zd_chip *chip, int led, enum led_status status);
-int zd_chip_led_flip(struct zd_chip *chip, int led,
-	             const unsigned int *phases_msecs, unsigned int count);
+int zd_chip_control_leds(struct zd_chip *chip, enum led_status status);
 
 int zd_set_beacon_interval(struct zd_chip *chip, u32 interval);
 
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.c b/drivers/net/wireless/zd1211rw/zd_mac.c
index 1989f1c..2d12837 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.c
+++ b/drivers/net/wireless/zd1211rw/zd_mac.c
@@ -33,6 +33,10 @@ #include "zd_util.h"
 static void ieee_init(struct ieee80211_device *ieee);
 static void softmac_init(struct ieee80211softmac_device *sm);
 
+static void housekeeping_init(struct zd_mac *mac);
+static void housekeeping_enable(struct zd_mac *mac);
+static void housekeeping_disable(struct zd_mac *mac);
+
 int zd_mac_init(struct zd_mac *mac,
 	        struct net_device *netdev,
 	        struct usb_interface *intf)
@@ -46,6 +50,7 @@ int zd_mac_init(struct zd_mac *mac,
 	ieee_init(ieee);
 	softmac_init(ieee80211_priv(netdev));
 	zd_chip_init(&mac->chip, netdev, intf);
+	housekeeping_init(mac);
 	return 0;
 }
 
@@ -178,6 +183,7 @@ int zd_mac_open(struct net_device *netde
 	if (r < 0)
 		goto disable_rx;
 
+	housekeeping_enable(mac);
 	ieee80211softmac_start(netdev);
 	return 0;
 disable_rx:
@@ -204,6 +210,7 @@ int zd_mac_stop(struct net_device *netde
 	 */
 
 	zd_chip_disable_rx(chip);
+	housekeeping_disable(mac);
 	ieee80211softmac_stop(netdev);
 
 	zd_chip_disable_hwint(chip);
@@ -1080,3 +1087,46 @@ void zd_dump_rx_status(const struct rx_s
 	}
 }
 #endif /* DEBUG */
+
+#define LINK_LED_WORK_DELAY HZ
+
+static void link_led_handler(void *p)
+{
+	struct zd_mac *mac = p;
+	struct zd_chip *chip = &mac->chip;
+	struct ieee80211softmac_device *sm = ieee80211_priv(mac->netdev);
+	int is_associated;
+	int r;
+
+	spin_lock_irq(&mac->lock);
+	is_associated = sm->associated != 0;
+	spin_unlock_irq(&mac->lock);
+
+	r = zd_chip_control_leds(chip,
+		                 is_associated ? LED_ASSOCIATED : LED_SCANNING);
+	if (r)
+		dev_err(zd_mac_dev(mac), "zd_chip_control_leds error %d\n", r);
+
+	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
+		           LINK_LED_WORK_DELAY);
+}
+
+static void housekeeping_init(struct zd_mac *mac)
+{
+	INIT_WORK(&mac->housekeeping.link_led_work, link_led_handler, mac);
+}
+
+static void housekeeping_enable(struct zd_mac *mac)
+{
+	dev_dbg_f(zd_mac_dev(mac), "\n");
+	queue_delayed_work(zd_workqueue, &mac->housekeeping.link_led_work,
+			   0);
+}
+
+static void housekeeping_disable(struct zd_mac *mac)
+{
+	dev_dbg_f(zd_mac_dev(mac), "\n");
+	cancel_rearming_delayed_workqueue(zd_workqueue,
+		&mac->housekeeping.link_led_work);
+	zd_chip_control_leds(&mac->chip, LED_OFF);
+}
diff --git a/drivers/net/wireless/zd1211rw/zd_mac.h b/drivers/net/wireless/zd1211rw/zd_mac.h
index 29b51fd..b8ea3de 100644
--- a/drivers/net/wireless/zd1211rw/zd_mac.h
+++ b/drivers/net/wireless/zd1211rw/zd_mac.h
@@ -120,6 +120,10 @@ enum mac_flags {
 	MAC_FIXED_CHANNEL = 0x01,
 };
 
+struct housekeeping {
+	struct work_struct link_led_work;
+};
+
 #define ZD_MAC_STATS_BUFFER_SIZE 16
 
 struct zd_mac {
@@ -128,6 +132,7 @@ struct zd_mac {
 	struct net_device *netdev;
 	/* Unlocked reading possible */
 	struct iw_statistics iw_stats;
+	struct housekeeping housekeeping;
 	unsigned int stats_count;
 	u8 qual_buffer[ZD_MAC_STATS_BUFFER_SIZE];
 	u8 rssi_buffer[ZD_MAC_STATS_BUFFER_SIZE];
diff --git a/drivers/net/wireless/zd1211rw/zd_netdev.c b/drivers/net/wireless/zd1211rw/zd_netdev.c
index 440ef24..af3a7b3 100644
--- a/drivers/net/wireless/zd1211rw/zd_netdev.c
+++ b/drivers/net/wireless/zd1211rw/zd_netdev.c
@@ -82,7 +82,7 @@ static int iw_get_nick(struct net_device
 		       union iwreq_data *req, char *extra)
 {
 	strcpy(extra, "zd1211");
-	req->data.length = strlen(extra) + 1;
+	req->data.length = strlen(extra);
 	req->data.flags = 1;
 	return 0;
 }
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.c b/drivers/net/wireless/zd1211rw/zd_usb.c
index 31027e5..5c265ad 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.c
+++ b/drivers/net/wireless/zd1211rw/zd_usb.c
@@ -24,6 +24,7 @@ #include <linux/device.h>
 #include <linux/errno.h>
 #include <linux/skbuff.h>
 #include <linux/usb.h>
+#include <linux/workqueue.h>
 #include <net/ieee80211.h>
 
 #include "zd_def.h"
@@ -1112,12 +1113,20 @@ static struct usb_driver driver = {
 	.disconnect	= disconnect,
 };
 
+struct workqueue_struct *zd_workqueue;
+
 static int __init usb_init(void)
 {
 	int r;
 
 	pr_debug("usb_init()\n");
 
+	zd_workqueue = create_singlethread_workqueue(driver.name);
+	if (zd_workqueue == NULL) {
+		printk(KERN_ERR "%s: couldn't create workqueue\n", driver.name);
+		return -ENOMEM;
+	}
+
 	r = usb_register(&driver);
 	if (r) {
 		printk(KERN_ERR "usb_register() failed. Error number %d\n", r);
@@ -1132,6 +1141,7 @@ static void __exit usb_exit(void)
 {
 	pr_debug("usb_exit()\n");
 	usb_deregister(&driver);
+	destroy_workqueue(zd_workqueue);
 }
 
 module_init(usb_init);
diff --git a/drivers/net/wireless/zd1211rw/zd_usb.h b/drivers/net/wireless/zd1211rw/zd_usb.h
index ded39de..e81a2d3 100644
--- a/drivers/net/wireless/zd1211rw/zd_usb.h
+++ b/drivers/net/wireless/zd1211rw/zd_usb.h
@@ -238,4 +238,6 @@ int zd_usb_iowrite16v(struct zd_usb *usb
 
 int zd_usb_rfwrite(struct zd_usb *usb, u32 value, u8 bits);
 
+extern struct workqueue_struct *zd_workqueue;
+
 #endif /* _ZD_USB_H */
diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 4328912..ac4f502 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -334,7 +334,6 @@ #define NETIF_F_ALL_CSUM	(NETIF_F_IP_CSU
 
 
 	struct net_device_stats* (*get_stats)(struct net_device *dev);
-	struct iw_statistics*	(*get_wireless_stats)(struct net_device *dev);
 
 	/* List of functions to handle Wireless Extensions (instead of ioctl).
 	 * See <net/iw_handler.h> for details. Jean II */
diff --git a/include/linux/wireless.h b/include/linux/wireless.h
index 1358856..a50a013 100644
--- a/include/linux/wireless.h
+++ b/include/linux/wireless.h
@@ -1,7 +1,7 @@
 /*
  * This file define a set of standard wireless extensions
  *
- * Version :	20	17.2.06
+ * Version :	21	14.3.06
  *
  * Authors :	Jean Tourrilhes - HPL - <jt@hpl.hp.com>
  * Copyright (c) 1997-2006 Jean Tourrilhes, All Rights Reserved.
@@ -69,9 +69,14 @@ #define _LINUX_WIRELESS_H
 
 /***************************** INCLUDES *****************************/
 
+/* This header is used in user-space, therefore need to be sanitised
+ * for that purpose. Those includes are usually not compatible with glibc.
+ * To know which includes to use in user-space, check iwlib.h. */
+#ifdef __KERNEL__
 #include <linux/types.h>		/* for "caddr_t" et al		*/
 #include <linux/socket.h>		/* for "struct sockaddr" et al	*/
 #include <linux/if.h>			/* for IFNAMSIZ and co... */
+#endif	/* __KERNEL__ */
 
 /***************************** VERSION *****************************/
 /*
@@ -80,7 +85,7 @@ #include <linux/if.h>			/* for IFNAMSIZ 
  * (there is some stuff that will be added in the future...)
  * I just plan to increment with each new version.
  */
-#define WIRELESS_EXT	20
+#define WIRELESS_EXT	21
 
 /*
  * Changes :
@@ -208,6 +213,14 @@ #define WIRELESS_EXT	20
  * V19 to V20
  * ----------
  *	- RtNetlink requests support (SET/GET)
+ *
+ * V20 to V21
+ * ----------
+ *	- Remove (struct net_device *)->get_wireless_stats()
+ *	- Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	- Add IW_RETRY_SHORT/IW_RETRY_LONG retry modifiers
+ *	- Power/Retry relative values no longer * 100000
+ *	- Add explicit flag to tell stats are in 802.11k RCPI : IW_QUAL_RCPI
  */
 
 /**************************** CONSTANTS ****************************/
@@ -448,6 +461,7 @@ #define IW_QUAL_DBM		0x08	/* Level + Noi
 #define IW_QUAL_QUAL_INVALID	0x10	/* Driver doesn't provide value */
 #define IW_QUAL_LEVEL_INVALID	0x20
 #define IW_QUAL_NOISE_INVALID	0x40
+#define IW_QUAL_RCPI		0x80	/* Level + Noise are 802.11k RCPI */
 #define IW_QUAL_ALL_INVALID	0x70
 
 /* Frequency flags */
@@ -500,10 +514,12 @@ #define IW_RETRY_ON		0x0000	/* No detail
 #define IW_RETRY_TYPE		0xF000	/* Type of parameter */
 #define IW_RETRY_LIMIT		0x1000	/* Maximum number of retries*/
 #define IW_RETRY_LIFETIME	0x2000	/* Maximum duration of retries in us */
-#define IW_RETRY_MODIFIER	0x000F	/* Modify a parameter */
+#define IW_RETRY_MODIFIER	0x00FF	/* Modify a parameter */
 #define IW_RETRY_MIN		0x0001	/* Value is a minimum  */
 #define IW_RETRY_MAX		0x0002	/* Value is a maximum */
 #define IW_RETRY_RELATIVE	0x0004	/* Value is not in seconds/ms/us */
+#define IW_RETRY_SHORT		0x0010	/* Value is for short packets  */
+#define IW_RETRY_LONG		0x0020	/* Value is for long packets */
 
 /* Scanning request flags */
 #define IW_SCAN_DEFAULT		0x0000	/* Default scan of the driver */
@@ -1017,7 +1033,7 @@ struct	iw_range
 	/* Note : this frequency list doesn't need to fit channel numbers,
 	 * because each entry contain its channel index */
 
-	__u32		enc_capa; /* IW_ENC_CAPA_* bit field */
+	__u32		enc_capa;	/* IW_ENC_CAPA_* bit field */
 };
 
 /*
diff --git a/net/core/net-sysfs.c b/net/core/net-sysfs.c
index 1347276..f47f319 100644
--- a/net/core/net-sysfs.c
+++ b/net/core/net-sysfs.c
@@ -344,8 +344,6 @@ static ssize_t wireless_show(struct clas
 		if(dev->wireless_handlers &&
 		   dev->wireless_handlers->get_wireless_stats)
 			iw = dev->wireless_handlers->get_wireless_stats(dev);
-		else if (dev->get_wireless_stats)
-			iw = dev->get_wireless_stats(dev);
 		if (iw != NULL)
 			ret = (*format)(iw, buf);
 	}
@@ -465,8 +463,7 @@ int netdev_register_sysfs(struct net_dev
 		*groups++ = &netstat_group;
 
 #ifdef WIRELESS_EXT
-	if (net->get_wireless_stats
-	    || (net->wireless_handlers && net->wireless_handlers->get_wireless_stats))
+	if (net->wireless_handlers && net->wireless_handlers->get_wireless_stats)
 		*groups++ = &wireless_group;
 #endif
 
diff --git a/net/core/wireless.c b/net/core/wireless.c
index 3168fca..ffff0da 100644
--- a/net/core/wireless.c
+++ b/net/core/wireless.c
@@ -68,6 +68,14 @@
  *
  * v8 - 17.02.06 - Jean II
  *	o RtNetlink requests support (SET/GET)
+ *
+ * v8b - 03.08.06 - Herbert Xu
+ *	o Fix Wireless Event locking issues.
+ *
+ * v9 - 14.3.06 - Jean II
+ *	o Change length in ESSID and NICK to strlen() instead of strlen()+1
+ *	o Make standard_ioctl_num and standard_event_num unsigned
+ *	o Remove (struct net_device *)->get_wireless_stats()
  */
 
 /***************************** INCLUDES *****************************/
@@ -234,24 +242,24 @@ static const struct iw_ioctl_description
 	[SIOCSIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_EVENT,
 	},
 	[SIOCGIWESSID	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 		.flags		= IW_DESCR_FLAG_DUMP,
 	},
 	[SIOCSIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCGIWNICKN	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_POINT,
 		.token_size	= 1,
-		.max_tokens	= IW_ESSID_MAX_SIZE + 1,
+		.max_tokens	= IW_ESSID_MAX_SIZE,
 	},
 	[SIOCSIWRATE	- SIOCIWFIRST] = {
 		.header_type	= IW_HEADER_TYPE_PARAM,
@@ -338,8 +346,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmksa),
 	},
 };
-static const int standard_ioctl_num = (sizeof(standard_ioctl) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_ioctl_num = (sizeof(standard_ioctl) /
+					    sizeof(struct iw_ioctl_description));
 
 /*
  * Meta-data about all the additional standard Wireless Extension events
@@ -389,8 +397,8 @@ static const struct iw_ioctl_description
 		.max_tokens	= sizeof(struct iw_pmkid_cand),
 	},
 };
-static const int standard_event_num = (sizeof(standard_event) /
-				       sizeof(struct iw_ioctl_description));
+static const unsigned standard_event_num = (sizeof(standard_event) /
+					    sizeof(struct iw_ioctl_description));
 
 /* Size (in bytes) of the various private data types */
 static const char iw_priv_type_size[] = {
@@ -465,17 +473,6 @@ static inline struct iw_statistics *get_
 	   (dev->wireless_handlers->get_wireless_stats != NULL))
 		return dev->wireless_handlers->get_wireless_stats(dev);
 
-	/* Old location, field to be removed in next WE */
-	if(dev->get_wireless_stats) {
-		static int printed_message;
-
-		if (!printed_message++)
-			printk(KERN_DEBUG "%s (WE) : Driver using old /proc/net/wireless support, please fix driver !\n",
-				dev->name);
-
-		return dev->get_wireless_stats(dev);
-	}
-
 	/* Not found */
 	return (struct iw_statistics *) NULL;
 }
@@ -1843,8 +1840,33 @@ #endif	/* CONFIG_NET_WIRELESS_RTNETLINK 
  */
 
 #ifdef WE_EVENT_RTNETLINK
+/* ---------------------------------------------------------------- */
+/*
+ * Locking...
+ * ----------
+ *
+ * Thanks to Herbert Xu <herbert@gondor.apana.org.au> for fixing
+ * the locking issue in here and implementing this code !
+ *
+ * The issue : wireless_send_event() is often called in interrupt context,
+ * while the Netlink layer can never be called in interrupt context.
+ * The fully formed RtNetlink events are queued, and then a tasklet is run
+ * to feed those to Netlink.
+ * The skb_queue is interrupt safe, and its lock is not held while calling
+ * Netlink, so there is no possibility of dealock.
+ * Jean II
+ */
+
 static struct sk_buff_head wireless_nlevent_queue;
 
+static int __init wireless_nlevent_init(void)
+{
+	skb_queue_head_init(&wireless_nlevent_queue);
+	return 0;
+}
+
+subsys_initcall(wireless_nlevent_init);
+
 static void wireless_nlevent_process(unsigned long data)
 {
 	struct sk_buff *skb;
@@ -1921,13 +1943,6 @@ static inline void rtmsg_iwinfo(struct n
 	tasklet_schedule(&wireless_nlevent_tasklet);
 }
 
-static int __init wireless_nlevent_init(void)
-{
-	skb_queue_head_init(&wireless_nlevent_queue);
-	return 0;
-}
-
-subsys_initcall(wireless_nlevent_init);
 #endif	/* WE_EVENT_RTNETLINK */
 
 /* ---------------------------------------------------------------- */
diff --git a/net/ieee80211/softmac/ieee80211softmac_wx.c b/net/ieee80211/softmac/ieee80211softmac_wx.c
index 75320b6..2aa779d 100644
--- a/net/ieee80211/softmac/ieee80211softmac_wx.c
+++ b/net/ieee80211/softmac/ieee80211softmac_wx.c
@@ -80,10 +80,10 @@ ieee80211softmac_wx_set_essid(struct net
 	 * If it's our network, ignore the change, we're already doing it!
 	 */
 	if((sm->associnfo.associating || sm->associated) &&
-	   (data->essid.flags && data->essid.length && extra)) {
+	   (data->essid.flags && data->essid.length)) {
 		/* Get the associating network */
 		n = ieee80211softmac_get_network_by_bssid(sm, sm->associnfo.bssid);
-		if(n && n->essid.len == (data->essid.length - 1) &&
+		if(n && n->essid.len == data->essid.length &&
 		   !memcmp(n->essid.data, extra, n->essid.len)) {
 			dprintk(KERN_INFO PFX "Already associating or associated to "MAC_FMT"\n",
 				MAC_ARG(sm->associnfo.bssid));
@@ -109,8 +109,8 @@ ieee80211softmac_wx_set_essid(struct net
 	sm->associnfo.static_essid = 0;
 	sm->associnfo.assoc_wait = 0;
 
-	if (data->essid.flags && data->essid.length && extra /*required?*/) {
-		length = min(data->essid.length - 1, IW_ESSID_MAX_SIZE);
+	if (data->essid.flags && data->essid.length) {
+		length = min((int)data->essid.length, IW_ESSID_MAX_SIZE);
 		if (length) {
 			memcpy(sm->associnfo.req_essid.data, extra, length);
 			sm->associnfo.static_essid = 1;
-- 
John W. Linville
linville@tuxdriver.com
