From: Joe Perches <joe@perches.com>
Subject: [PATCH] rtlwifi: rtl8192cu: Fix memset using sizeof(ptr) not
 sizeof(*ptr)
Date: Sun, 08 May 2011 22:43:52 -0700
Message-ID: <1304919832.19586.15.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>
To: Larry Finger <Larry.Finger@lwfinger.net>,
	Chaoming Li <chaoming_li@realsil.com.cn>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Found via coccinelle script

@@
type T;
T* ptr;
expression E1;
@@

* memset(E1, 0, sizeof(ptr));

Signed-off-by: Joe Perches <joe@perches.com>
---
 drivers/net/wireless/rtlwifi/rtl8192cu/trx.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
index 79c98f6..c16fc1c 100644
--- a/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
+++ b/drivers/net/wireless/rtlwifi/rtl8192cu/trx.c
@@ -372,7 +372,7 @@ static void _rtl_rx_process(struct ieee80211_hw *hw, struct sk_buff *skb)
 	__le16 fc;
 	struct ieee80211_hdr *hdr;
 
-	memset(rx_status, 0, sizeof(rx_status));
+	memset(rx_status, 0, sizeof(*rx_status));
 	rxdesc	= skb->data;
 	skb_len	= skb->len;
 	drvinfo_len = (GET_RX_DESC_DRVINFO_SIZE(rxdesc) * RTL_RX_DRV_INFO_UNIT);
