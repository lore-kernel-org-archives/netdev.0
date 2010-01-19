From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] af_packet: Don't use skb after dev_queue_xmit()
Date: Tue, 19 Jan 2010 10:47:39 +0000
Message-ID: <20100119104739.GA9088@ff.dom.local>
References: <20100118073018.GA6270@ff.dom.local> <4B548C6B.10607@majjas.com> <20100118204658.GC3157@del.dom.local> <4B54CB0D.5070604@majjas.com> <20100118212516.GE3157@del.dom.local> <4B54D50C.90608@majjas.com> <20100118220814.GG3157@del.dom.local> <20100118221747.GH3157@del.dom.local> <4B54E4EF.8080602@majjas.com> <4B554730.6090000@majjas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	flyboy@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Michael Breuer <mbreuer@majjas.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932169Ab0ASKrr@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <4B554730.6090000@majjas.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jan 19, 2010 at 12:46:24AM -0500, Michael Breuer wrote:
> Ok - one last update for a while ...not sure what's next... I put some  
> printk's into sky2.c xmit logic - the packets are being sent to the  
...

Btw, could you try if this patch can makes difference in triggering
the "lib/dma-debug.c:898" warning?

Jarek P.
---

 drivers/net/sky2.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/drivers/net/sky2.c b/drivers/net/sky2.c
index 7650f73..e02e9e9 100644
--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2479,6 +2479,9 @@ static int sky2_status_intr(struct sky2_hw *hw, int to_do, u16 idx)
 
 		port = le->css & CSS_LINK_BIT;
 		dev = hw->dev[port];
+		if (!netif_running(dev))
+			continue;
+
 		sky2 = netdev_priv(dev);
 		length = le16_to_cpu(le->length);
 		status = le32_to_cpu(le->status);
