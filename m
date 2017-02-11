From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 7/7] staging: r8712u: Fix Sparse warnings in rtl871x_mlme.c
Date: Fri, 10 Feb 2017 21:30:30 -0600
Message-ID: <20170211033030.28827-8-Larry.Finger@lwfinger.net>
References: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170211033030.28827-1-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

Sparse reports the following:
  CHECK   drivers/staging/rtl8712/rtl871x_mlme.c
drivers/staging/rtl8712/rtl871x_mlme.c:1653:46: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8712/rtl871x_mlme.c:1653:46:    expected unsigned int [unsigned] [usertype] DSConfig
drivers/staging/rtl8712/rtl871x_mlme.c:1653:46:    got restricted __le32 [usertype] <noident>
drivers/staging/rtl8712/rtl871x_mlme.c:1656:56: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8712/rtl871x_mlme.c:1656:56:    expected unsigned int [unsigned] [usertype] ATIMWindow
drivers/staging/rtl8712/rtl871x_mlme.c:1656:56:    got restricted __le32 [usertype] <noident>
drivers/staging/rtl8712/rtl871x_mlme.c:1712:35: warning: incorrect type in assignment (different base types)
drivers/staging/rtl8712/rtl871x_mlme.c:1712:35:    expected restricted __le16 [addressable] [usertype] cap_info
drivers/staging/rtl8712/rtl871x_mlme.c:1712:35:    got int

Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
---
 drivers/staging/rtl8712/rtl871x_mlme.c | 9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_mlme.c b/drivers/staging/rtl8712/rtl871x_mlme.c
index fd8d96d..bf1ac22 100644
--- a/drivers/staging/rtl8712/rtl871x_mlme.c
+++ b/drivers/staging/rtl8712/rtl871x_mlme.c
@@ -1650,10 +1650,9 @@ void r8712_update_registrypriv_dev_network(struct _adapter *adapter)
 		/* TODO */
 		break;
 	}
-	pdev_network->Configuration.DSConfig = cpu_to_le32(
-					       pregistrypriv->channel);
+	pdev_network->Configuration.DSConfig = pregistrypriv->channel;
 	if (cur_network->network.InfrastructureMode == Ndis802_11IBSS)
-		pdev_network->Configuration.ATIMWindow = cpu_to_le32(3);
+		pdev_network->Configuration.ATIMWindow = 3;
 	pdev_network->InfrastructureMode = cur_network->network.InfrastructureMode;
 	/* 1. Supported rates
 	 * 2. IE
@@ -1709,12 +1708,12 @@ unsigned int r8712_restructure_ht_ie(struct _adapter *padapter, u8 *in_ie,
 		}
 		out_len = *pout_len;
 		memset(&ht_capie, 0, sizeof(struct ieee80211_ht_cap));
-		ht_capie.cap_info = IEEE80211_HT_CAP_SUP_WIDTH |
+		ht_capie.cap_info = cpu_to_le16(IEEE80211_HT_CAP_SUP_WIDTH |
 				    IEEE80211_HT_CAP_SGI_20 |
 				    IEEE80211_HT_CAP_SGI_40 |
 				    IEEE80211_HT_CAP_TX_STBC |
 				    IEEE80211_HT_CAP_MAX_AMSDU |
-				    IEEE80211_HT_CAP_DSSSCCK40;
+				    IEEE80211_HT_CAP_DSSSCCK40);
 		ht_capie.ampdu_params_info = (IEEE80211_HT_CAP_AMPDU_FACTOR &
 				0x03) | (IEEE80211_HT_CAP_AMPDU_DENSITY & 0x00);
 		r8712_set_ie(out_ie + out_len, _HT_CAPABILITY_IE_,
-- 
2.10.2
