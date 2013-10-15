From: Kefeng Wang <wangkefeng.wang@huawei.com>
Subject: [PATCH 12/18] net: irda: use wrapper functions of net_ratelimit() to simplify code
Date: Tue, 15 Oct 2013 19:45:08 +0800
Message-ID: <1381837514-50660-13-git-send-email-wangkefeng.wang@huawei.com>
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
 drivers/net/irda/stir4200.c | 3 +--
 1 file changed, 1 insertion(+), 2 deletions(-)

diff --git a/drivers/net/irda/stir4200.c b/drivers/net/irda/stir4200.c
index 876e709..d499b2b 100644
--- a/drivers/net/irda/stir4200.c
+++ b/drivers/net/irda/stir4200.c
@@ -783,8 +783,7 @@ static int stir_transmit_thread(void *arg)
 				break;
 
 			if (unlikely(receive_start(stir))) {
-				if (net_ratelimit())
-					dev_info(&dev->dev,
+				net_ratelimited_function(dev_info, &dev->dev,
 						 "%s: receive usb submit failed\n",
 						 stir->netdev->name);
 				stir->receiving = 0;
-- 
1.8.2.1
