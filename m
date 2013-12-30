From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 9/11] ipw2x00: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:15:05 +0100
Message-ID: <1388427307-8691-10-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Stanislav Yakovlev <stas.yakovlev@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structure involved is
libipw_network defined in drivers/net/wireless/ipw2x00/libipw.h

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/ipw2x00/libipw_rx.c |    2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/net/wireless/ipw2x00/libipw_rx.c b/drivers/net/wireless/ipw2x00/libipw_rx.c
index 9ffe659..ce27859 100644
--- a/drivers/net/wireless/ipw2x00/libipw_rx.c
+++ b/drivers/net/wireless/ipw2x00/libipw_rx.c
@@ -1468,7 +1468,7 @@ static inline int is_same_network(struct libipw_network *src,
 	 * as one network */
 	return ((src->ssid_len == dst->ssid_len) &&
 		(src->channel == dst->channel) &&
-		ether_addr_equal(src->bssid, dst->bssid) &&
+		ether_addr_equal_64bits(src->bssid, dst->bssid) &&
 		!memcmp(src->ssid, dst->ssid, src->ssid_len));
 }
 
