From: Denis Kirjanov <dkirjanov@kernel.org>
Subject: Re: Fwd: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
Date: Mon, 01 Nov 2010 19:29:30 +0300
Message-ID: <4CCEEAEA.4050504@kernel.org>
References: <1288253909-12084-1-git-send-email-mad_soft@inbox.ru> <AANLkTi=B93UqfiBFMFryLk1wxus6LwHsSo+8+Ff5D0Ne@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: David Brownell <dbrownell@users.sourceforge.net>,
	Greg Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>,
	"David S. Miller" <davem@davemloft.net>
To: mad_soft@inbox.ru
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=B93UqfiBFMFryLk1wxus6LwHsSo+8+Ff5D0Ne@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 11/01/2010 07:12 PM, Denis Kirjanov wrote:
> ---------- Forwarded message ----------
> From: Dmitry Artamonow <mad_soft@inbox.ru>
> Date: Thu, Oct 28, 2010 at 12:18 PM
> Subject: [PATCH] USB: gadget: fix ethernet gadget crash in gether_setup
> To: linux-usb@vger.kernel.org
> Cc: David Brownell <dbrownell@users.sourceforge.net>, Greg
> Kroah-Hartman <gregkh@suse.de>, netdev@vger.kernel.org,
> linux-kernel@vger.kernel.org, Tom Herbert <therbert@google.com>,
> "David S. Miller" <davem@davemloft.net>
> 
> 
> Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
> register_netdevice"), which moved tx netqueue creation into register_netdev.
> So now calling netif_stop_queue() before register_netdev causes an oops.
> Move netif_stop_queue() after net device registration to fix crash.
> 
> Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
> ---

Doesn't this is racy with the ->open? eth_open invokes netif_wake_queue() inside eth_start


[PATCH] USB: gadget: fix ethernet gadget crash in gether_setup

Crash is triggered by commit e6484930d7 ("net: allocate tx queues in
register_netdevice"), which moved tx netqueue creation into register_netdev.
So now calling netif_stop_queue() before register_netdev causes an oops.
Move netif_stop_queue() after net device registration to fix crash.

Signed-off-by: Dmitry Artamonow <mad_soft@inbox.ru>
Signed-off-by: Denis Kirjanov <dkirjanov@kernel.org>
---
 drivers/usb/gadget/u_ether.c |    1 -
 1 files changed, 0 insertions(+), 1 deletions(-)

diff --git a/drivers/usb/gadget/u_ether.c b/drivers/usb/gadget/u_ether.c
index cb23355..fbe86ca 100644
--- a/drivers/usb/gadget/u_ether.c
+++ b/drivers/usb/gadget/u_ether.c
@@ -811,7 +811,6 @@ int gether_setup(struct usb_gadget *g, u8 ethaddr[ETH_ALEN])
 		INFO(dev, "MAC %pM\n", net->dev_addr);
 		INFO(dev, "HOST MAC %pM\n", dev->host_mac);
 
-		netif_stop_queue(net);
 		the_dev = dev;
 	}
 
-- 
1.7.1
