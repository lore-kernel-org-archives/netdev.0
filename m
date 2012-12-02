From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch] p54: potential signedness issue in p54_parse_rssical()
Date: Sun, 2 Dec 2012 13:36:09 +0300
Message-ID: <20121202103609.GA16078@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-janitors@vger.kernel.org
To: Christian Lamparter <chunkeey@googlemail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

"entries" is unsigned here, so it is never less than zero.  In theory,
len could be less than offset so I have added a check for that.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>

diff --git a/drivers/net/wireless/p54/eeprom.c b/drivers/net/wireless/p54/eeprom.c
index 1ef1bfe..d43e374 100644
--- a/drivers/net/wireless/p54/eeprom.c
+++ b/drivers/net/wireless/p54/eeprom.c
@@ -541,8 +541,9 @@ static int p54_parse_rssical(struct ieee80211_hw *dev,
 		entries = (len - offset) /
 			sizeof(struct pda_rssi_cal_ext_entry);
 
-		if ((len - offset) % sizeof(struct pda_rssi_cal_ext_entry) ||
-		    entries <= 0) {
+		if (len < offset ||
+		    (len - offset) % sizeof(struct pda_rssi_cal_ext_entry) ||
+		    entries == 0) {
 			wiphy_err(dev->wiphy, "invalid rssi database.\n");
 			goto err_data;
 		}
