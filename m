From: Jean Tourrilhes <jt@hpl.hp.com>
Subject: [PATCH 2.6] More WE-21 potential overflows...
Date: Mon, 2 Oct 2006 17:58:04 -0700
Message-ID: <20061003005804.GB15997@bougret.hpl.hp.com>
Reply-To: jt@hpl.hp.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from gundega.hpl.hp.com ([192.6.19.190]:13011 "EHLO
	gundega.hpl.hp.com") by vger.kernel.org with ESMTP id S1030200AbWJCA6h
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 20:58:37 -0400
To: "John W. Linville" <linville@tuxdriver.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

	Hi,

	After the Orinoco issue, I did an audit of other drivers for
the same issue. Three drivers were NULL terminating the ESSID, which
could cause an overflow in WE-21 when the ESSID has maximum size.

	Sorry for having overlooked that...

	Jean


Signed-off-by: Jean Tourrilhes <jt@hpl.hp.com>

-----------------------------------------------------------

diff -u -p linux/drivers/net/wireless/airo.j1.c linux/drivers/net/wireless/airo.c
--- linux/drivers/net/wireless/airo.j1.c	2006-10-02 17:40:43.000000000 -0700
+++ linux/drivers/net/wireless/airo.c	2006-10-02 17:41:32.000000000 -0700
@@ -5910,7 +5910,6 @@ static int airo_get_essid(struct net_dev
 
 	/* Get the current SSID */
 	memcpy(extra, status_rid.SSID, status_rid.SSIDlen);
-	extra[status_rid.SSIDlen] = '\0';
 	/* If none, we may want to get the one that was set */
 
 	/* Push it out ! */
diff -u -p linux/drivers/net/wireless/atmel.j1.c linux/drivers/net/wireless/atmel.c
--- linux/drivers/net/wireless/atmel.j1.c	2006-10-02 17:40:51.000000000 -0700
+++ linux/drivers/net/wireless/atmel.c	2006-10-02 17:41:59.000000000 -0700
@@ -1678,11 +1678,9 @@ static int atmel_get_essid(struct net_de
 	/* Get the current SSID */
 	if (priv->new_SSID_size != 0) {
 		memcpy(extra, priv->new_SSID, priv->new_SSID_size);
-		extra[priv->new_SSID_size] = '\0';
 		dwrq->length = priv->new_SSID_size;
 	} else {
 		memcpy(extra, priv->SSID, priv->SSID_size);
-		extra[priv->SSID_size] = '\0';
 		dwrq->length = priv->SSID_size;
 	}
 
diff -u -p linux/drivers/net/wireless/ray_cs.j1.c linux/drivers/net/wireless/ray_cs.c
--- linux/drivers/net/wireless/ray_cs.j1.c	2006-10-02 17:40:58.000000000 -0700
+++ linux/drivers/net/wireless/ray_cs.c	2006-10-02 17:42:41.000000000 -0700
@@ -1198,7 +1198,6 @@ static int ray_get_essid(struct net_devi
 
 	/* Get the essid that was set */
 	memcpy(extra, local->sparm.b5.a_current_ess_id, IW_ESSID_MAX_SIZE);
-	extra[IW_ESSID_MAX_SIZE] = '\0';
 
 	/* Push it out ! */
 	dwrq->length = strlen(extra);
