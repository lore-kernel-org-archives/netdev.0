From: Anton Blanchard <anton@samba.org>
Subject: Re: [PATCH 1/2] e1000: Fix DMA mapping error handling
	on TX
Date: Sun, 24 Jan 2010 11:47:53 +1100
Message-ID: <20100124004753.GB2996@kryten>
References: <20100121114244.GC32259@kryten>
	<9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Yi Zou <yi.zou@intel.com>, e1000-devel@lists.sourceforge.net,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	John Ronciak <john.ronciak@intel.com>, netdev@vger.kernel.org,
	Roel Kluin <roel.kluin@gmail.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <e1000-devel-bounces@lists.sourceforge.net>
Content-Disposition: inline
In-Reply-To: <9929d2391001221940r4482dde4k8e5409bc7933bc21@mail.gmail.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=e1000-devel>
List-Post: <mailto:e1000-devel@lists.sourceforge.net>
List-Help: <mailto:e1000-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/e1000-devel>,
	<mailto:e1000-devel-request@lists.sourceforge.net?subject=subscribe>
Errors-To: e1000-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

 
Hi,

> This patch does not apply to the current e1000 driver in net-2.6, much
> of this patch has already been corrected (applied) by Roel Kluin
> recent patch.

Sorry I was basing off net-next. I just compared it to my fix and looks like
the patch in net-2.6 has an off by one error doesn't it?

Anton

--

Subject: [PATCH] e1000: Fix DMA mapping error handling on TX

e1000_tx_map has an off by one error in the dma mapping error cleanup path.
We decrement count and never clean the first successfully mapped descriptor.

Signed-off-by: Anton Blanchard <anton@samba.org>
---

diff --git a/drivers/net/e1000/e1000_main.c b/drivers/net/e1000/e1000_main.c
index d29bb53..427cedd 100644
--- a/drivers/net/e1000/e1000_main.c
+++ b/drivers/net/e1000/e1000_main.c
@@ -2790,8 +2790,6 @@ static int e1000_tx_map(struct e1000_adapter *adapter,
 dma_error:
 	dev_err(&pdev->dev, "TX DMA map failed\n");
 	buffer_info->dma = 0;
-	if (count)
-		count--;
 
 	while (count--) {
 		if (i==0)

------------------------------------------------------------------------------
Throughout its 18-year history, RSA Conference consistently attracts the
world's best and brightest in the field, creating opportunities for Conference
attendees to learn about information security's most important issues through
interactions with peers, luminaries and emerging and established companies.
http://p.sf.net/sfu/rsaconf-dev2dev
_______________________________________________
E1000-devel mailing list
E1000-devel@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/e1000-devel
To learn more about Intel&#174; Ethernet, visit http://communities.intel.com/community/wired
