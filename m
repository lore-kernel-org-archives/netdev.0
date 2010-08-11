From: Christoph Fritz <chf.fritz@googlemail.com>
Subject: [PATCH 2/2] ipw2100: add WEXT scan capabilities
Date: Wed, 11 Aug 2010 21:33:15 +0200
Message-ID: <1281555195.4367.3.camel@lovely.krouter>
References: <1281555063.4367.1.camel@lovely.krouter>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Zhu Yi <yi.zhu@intel.com>, "David S. Miller" <davem@davemloft.net>,
	Joe Perches <joe@perches.com>,
	"Rafael J. Wysocki" <rjw@sisk.pl>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: "John W. Linville" <linville@tuxdriver.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1281555063.4367.1.camel@lovely.krouter>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NetworkManager claims: "driver does not support SSID scans (scan_capa
0x00)". This patch adds scan capabilities.

Signed-off-by: Christoph Fritz <chf.fritz@googlemail.com>
---
 drivers/net/wireless/ipw2x00/ipw2100.c |    5 ++++-
 1 files changed, 4 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/ipw2x00/ipw2100.c b/drivers/net/wireless/ipw2x00/ipw2100.c
index df8e535..c330da4 100644
--- a/drivers/net/wireless/ipw2x00/ipw2100.c
+++ b/drivers/net/wireless/ipw2x00/ipw2100.c
@@ -6982,12 +6982,15 @@ static int ipw2100_wx_get_range(struct net_device *dev,
 
 	/* Event capability (kernel + driver) */
 	range->event_capa[0] = (IW_EVENT_CAPA_K_0 |
-				IW_EVENT_CAPA_MASK(SIOCGIWAP));
+				IW_EVENT_CAPA_MASK(SIOCGIWAP) |
+				IW_EVENT_CAPA_MASK(SIOCGIWSCAN));
 	range->event_capa[1] = IW_EVENT_CAPA_K_1;
 
 	range->enc_capa = IW_ENC_CAPA_WPA | IW_ENC_CAPA_WPA2 |
 		IW_ENC_CAPA_CIPHER_TKIP | IW_ENC_CAPA_CIPHER_CCMP;
 
+	range->scan_capa = IW_SCAN_CAPA_ESSID | IW_SCAN_CAPA_TYPE;
+
 	IPW_DEBUG_WX("GET Range\n");
 
 	return 0;
-- 
1.7.1
