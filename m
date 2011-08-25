From: Stephen Rothwell <sfr@canb.auug.org.au>
Subject: linux-next: build failure after merge of the staging tree
Date: Thu, 25 Aug 2011 15:02:09 +1000
Message-ID: <20110825150209.5d159c549777290de4644bcf@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	wlanfae <wlanfae@realtek.com>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jiri Pirko <jpirko@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Greg,

After merging the staging tree, today's linux-next build (x86_64
allmodconfig) failed like this:

drivers/staging/rtl8192e/rtl_core.c:2917:2: error: unknown field 'ndo_set_multicast_list' specified in initializer

Caused by commit 94a799425eee ("From: wlanfae <wlanfae@realtek.com>" -
really "[PATCH 1/8] rtl8192e: Import new version of driver from realtek"
Larry, that patch was badly imported ...) interacting with commit
b81693d9149c ("net: remove ndo_set_multicast_list callback") from the net
tree.

I applied the following patch (which seems to be what was done to the
other drivers in the net tree - there is probably more required):

From: Stephen Rothwell <sfr@canb.auug.org.au>
Date: Thu, 25 Aug 2011 14:57:55 +1000
Subject: [PATCH] rtl8192e: update for ndo_set_multicast_list removal.

Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
---
 drivers/staging/rtl8192e/rtl_core.c |    2 +-
 1 files changed, 1 insertions(+), 1 deletions(-)

diff --git a/drivers/staging/rtl8192e/rtl_core.c b/drivers/staging/rtl8192e/rtl_core.c
index f8a13d9..b38f626 100644
--- a/drivers/staging/rtl8192e/rtl_core.c
+++ b/drivers/staging/rtl8192e/rtl_core.c
@@ -2914,7 +2914,7 @@ static const struct net_device_ops rtl8192_netdev_ops = {
 	.ndo_stop = rtl8192_close,
 	.ndo_tx_timeout = rtl8192_tx_timeout,
 	.ndo_do_ioctl = rtl8192_ioctl,
-	.ndo_set_multicast_list = r8192_set_multicast,
+	.ndo_set_rx_mode = r8192_set_multicast,
 	.ndo_set_mac_address = r8192_set_mac_adr,
 	.ndo_validate_addr = eth_validate_addr,
 	.ndo_change_mtu = eth_change_mtu,
-- 
1.7.5.4

-- 
Cheers,
Stephen Rothwell                    sfr@canb.auug.org.au
http://www.canb.auug.org.au/~sfr/
