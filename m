From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: [PATCH net-next 2/2] iwlwifi: small compile warnings without
	CONFIG_IWLWIFI_DEBUG
Date: Thu, 17 Jul 2008 19:05:06 +0400
Message-ID: <1216307106.7034.15.camel@iris.sw.ru>
References: <1216286365-11703-1-git-send-email-den@openvz.org>
	 <1216286365-11703-2-git-send-email-den@openvz.org>
	 <1ba2fa240807170408w13837d67hcfd1be50fdb07738@mail.gmail.com>
	 <1216293987.7034.5.camel@iris.sw.ru>
	 <1ba2fa240807170437j12547b26l803551b61a805f8d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-WgpTvVap9qtmHeH0SCCD"
Cc: Netdev List <netdev@vger.kernel.org>
To: Tomas Winkler <tomasw@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:18251 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755752AbYGQPEG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 Jul 2008 11:04:06 -0400
In-Reply-To: <1ba2fa240807170437j12547b26l803551b61a805f8d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-WgpTvVap9qtmHeH0SCCD
Content-Type: text/plain
Content-Transfer-Encoding: 7bit

> > If you agree with this, I'll resend the patch with
> > iwl_rx_scan_results_notif modified.
> 
> Anyhow please send the patch only for scanning. I will apply the rs
> portion on our new code, which is still not visible...just to avoid
> conflict. I will keep  your credit
> Thanks
> Tomas

could I have your ack for this?

--=-WgpTvVap9qtmHeH0SCCD
Content-Disposition: attachment; filename*0=0002-iwlwifi-small-compile-warnings-without-CONFIG_IWLWI.patc; filename*1=h
Content-Type: application/mbox; name=0002-iwlwifi-small-compile-warnings-without-CONFIG_IWLWI.patch
Content-Transfer-Encoding: 7bit

>From 7a042651ec96a453e1fd4e4531f834367ea8ffe7 Mon Sep 17 00:00:00 2001
From: Denis V. Lunev <den@openvz.org>
Date: Thu, 17 Jul 2008 18:57:26 +0400
Subject: [PATCH net-next 2/2][v2] iwlwifi: small compile warnings without CONFIG_IWLWIFI_DEBUG

CC [M]  drivers/net/wireless/iwlwifi/iwl-scan.o
drivers/net/wireless/iwlwifi/iwl-scan.c: In function 'iwl_rx_scan_complete_notif':
drivers/net/wireless/iwlwifi/iwl-scan.c:274: warning: unused variable 'scan_notif'

Signed-off-by: Denis V. Lunev <den@openvz.org>
---
 drivers/net/wireless/iwlwifi/iwl-scan.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/wireless/iwlwifi/iwl-scan.c b/drivers/net/wireless/iwlwifi/iwl-scan.c
index efc750d..5a00ac2 100644
--- a/drivers/net/wireless/iwlwifi/iwl-scan.c
+++ b/drivers/net/wireless/iwlwifi/iwl-scan.c
@@ -270,6 +270,7 @@ static void iwl_rx_scan_results_notif(struct iwl_priv *priv,
 static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 				       struct iwl_rx_mem_buffer *rxb)
 {
+#ifdef CONFIG_IWLWIFI_DEBUG
 	struct iwl_rx_packet *pkt = (struct iwl_rx_packet *)rxb->skb->data;
 	struct iwl_scancomplete_notification *scan_notif = (void *)pkt->u.raw;
 
@@ -277,6 +278,7 @@ static void iwl_rx_scan_complete_notif(struct iwl_priv *priv,
 		       scan_notif->scanned_channels,
 		       scan_notif->tsf_low,
 		       scan_notif->tsf_high, scan_notif->status);
+#endif
 
 	/* The HW is no longer scanning */
 	clear_bit(STATUS_SCAN_HW, &priv->status);
-- 
1.5.4.5


--=-WgpTvVap9qtmHeH0SCCD--

