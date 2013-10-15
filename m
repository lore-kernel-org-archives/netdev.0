From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 10/18] net: peak_usb: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:06 +0800
Message-ID: <1381837514-50660-11-git-send-email-wangkefeng.wang@huawei.com>
References: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Pablo Neira Ayuso <pablo@netfilter.org>,
	"Stephen Hemminger" <stephen@networkplumber.org>,
	Johannes Berg <johannes@sipsolutions.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	Stanislaw Gruszka <sgruszka@redhat.com>,
	Johannes Berg <johannes.berg@intel.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	"Ben Hutchings" <bhutchings@solarflare.com>,
	Chas Williams <chas@cmf.nrl.navy.mil>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Samuel Ortiz <samuel@sortiz.org>,
	Paul Mackerras <paulus@samba.org>,
	Oliver Neukum <oneukum@suse.de>,
	Konrad Rzeszutek Wilk <konrad.wilk@oracle.com>,
	"Boris Ostrovsky" <boris.ostrovsky@oracle.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Rusty Russell <rusty@rustcorp.com.au>,
	"Michael S. Tsirkin" <mst@redhat.com>, <netfilter@vger.kernel.org>,
	<netdev@vger.ker
To: <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1381837514-50660-1-git-send-email-wangkefeng.wang@huawei.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

net_ratelimited_function() is called to simplify code.

Signed-off-by: Kefeng Wang <wangkefeng.wang@huawei.com>
---
 drivers/net/can/usb/peak_usb/pcan_usb_core.c | 11 ++++-------
 1 file changed, 4 insertions(+), 7 deletions(-)

diff --git a/drivers/net/can/usb/peak_usb/pcan_usb_core.c b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
index 0b7a4c3..5166a1f 100644
--- a/drivers/net/can/usb/peak_usb/pcan_usb_core.c
+++ b/drivers/net/can/usb/peak_usb/pcan_usb_core.c
@@ -191,8 +191,7 @@ static void peak_usb_read_bulk_callback(struct urb *urb)
 		return;
 
 	default:
-		if (net_ratelimit())
-			netdev_err(netdev,
+		net_ratelimited_function(netdev_err, netdev,
 				   "Rx urb aborted (%d)\n", urb->status);
 		goto resubmit_urb;
 	}
@@ -260,9 +259,8 @@ static void peak_usb_write_bulk_callback(struct urb *urb)
 		break;
 
 	default:
-		if (net_ratelimit())
-			netdev_err(netdev, "Tx urb aborted (%d)\n",
-				   urb->status);
+		net_ratelimited_function(netdev_err, netdev,
+			"Tx urb aborted (%d)\n", urb->status);
 	case -EPROTO:
 	case -ENOENT:
 	case -ECONNRESET:
@@ -314,8 +312,7 @@ static netdev_tx_t peak_usb_ndo_start_xmit(struct sk_buff *skb,
 
 	err = dev->adapter->dev_encode_msg(dev, skb, obuf, &size);
 	if (err) {
-		if (net_ratelimit())
-			netdev_err(netdev, "packet dropped\n");
+		net_ratelimited_function(netdev_err, netdev, "packet dropped\n");
 		dev_kfree_skb(skb);
 		stats->tx_dropped++;
 		return NETDEV_TX_OK;
-- 
1.8.2.1
