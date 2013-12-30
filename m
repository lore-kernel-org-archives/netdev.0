From: Julia Lawall <Julia.Lawall@lip6.fr>
Subject: [PATCH 1/11] rt2x00: use ether_addr_equal_64bits
Date: Mon, 30 Dec 2013 19:14:57 +0100
Message-ID: <1388427307-8691-2-git-send-email-Julia.Lawall@lip6.fr>
References: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Cc: kernel-janitors@vger.kernel.org,
	Gertjan van Wingerde <gwingerde@gmail.com>,
	Helmut Schaa <helmut.schaa@googlemail.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-wireless@vger.kernel.org, users@rt2x00.serialmonkey.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Ivo van Doorn <IvDoorn@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1388427307-8691-1-git-send-email-Julia.Lawall@lip6.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Julia Lawall <Julia.Lawall@lip6.fr>

Ether_addr_equal_64bits is more efficient than ether_addr_equal, and can be
used when each argument is an array within a structure that contains at
least two bytes of data beyond the array.

The structures involved are:
ieee80211_bar defined in include/linux/ieee80211.h and
rt2x00_bar_list_entry defined in drivers/net/wireless/rt2x00/rt2x00.h.

This was done using Coccinelle (http://coccinelle.lip6.fr/).

Signed-off-by: Julia Lawall <Julia.Lawall@lip6.fr>

---
The semantic patch used is rather long and can be found in message 0 of
this patch series.

 drivers/net/wireless/rt2x00/rt2x00dev.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/wireless/rt2x00/rt2x00dev.c b/drivers/net/wireless/rt2x00/rt2x00dev.c
index 00c3fae..2bde672 100644
--- a/drivers/net/wireless/rt2x00/rt2x00dev.c
+++ b/drivers/net/wireless/rt2x00/rt2x00dev.c
@@ -565,10 +565,10 @@ static void rt2x00lib_rxdone_check_ba(struct rt2x00_dev *rt2x00dev,
 
 #undef TID_CHECK
 
-		if (!ether_addr_equal(ba->ra, entry->ta))
+		if (!ether_addr_equal_64bits(ba->ra, entry->ta))
 			continue;
 
-		if (!ether_addr_equal(ba->ta, entry->ra))
+		if (!ether_addr_equal_64bits(ba->ta, entry->ra))
 			continue;
 
 		/* Mark BAR since we received the according BA */
