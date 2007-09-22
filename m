From: Satyam Sharma <satyam@infradead.org>
Subject: [PATCH -mm] pasemi_mac: Build fix after recent netdev stats
 changes
Date: Sat, 22 Sep 2007 13:10:32 +0530 (IST)
Message-ID: <alpine.LFD.0.999.0709221308300.22517@enigma.security.iitk.ac.in>
References: <20070918011841.2381bd93.akpm@linux-foundation.org>
 <20070920132512.GF24105@skynet.ie>
 <alpine.LFD.0.999.0709201903180.17093@enigma.security.iitk.ac.in>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=UTF-8
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Linux Netdev Mailing List <netdev@vger.kernel.org>,
	Jeff Garzik <jeff@garzik.org>,
	David Miller <davem@davemloft.net>
To: Mel Gorman <mel@skynet.ie>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:59561 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751230AbXIVHhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 22 Sep 2007 03:37:36 -0400
In-Reply-To: <alpine.LFD.0.999.0709201903180.17093@enigma.security.iitk.ac.in>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Thu, 20 Sep 2007, Satyam Sharma wrote:
> 
> BTW ppc64_defconfig didn't quite like 2.6.23-rc6-mm1 either ...
> IIRC I got build failures in:

> drivers/net/pasemi_mac.c


[PATCH -mm] pasemi_mac: Build fix after recent netdev stats changes

Unbreak the following:

drivers/net/pasemi_mac.c: In function 'pasemi_mac_clean_rx':
drivers/net/pasemi_mac.c:533: error: 'dev' undeclared (first use in this function)
drivers/net/pasemi_mac.c:533: error: (Each undeclared identifier is reported only once
drivers/net/pasemi_mac.c:533: error: for each function it appears in.)

And remove an unused static function:

drivers/net/pasemi_mac.c: At top level:
drivers/net/pasemi_mac.c:89: warning: 'read_iob_reg' defined but not used

Signed-off-by: Satyam Sharma <satyam@infradead.org>

---

 drivers/net/pasemi_mac.c |    9 ++-------
 1 file changed, 2 insertions(+), 7 deletions(-)

diff -ruNp a/drivers/net/pasemi_mac.c b/drivers/net/pasemi_mac.c
--- a/drivers/net/pasemi_mac.c	2007-09-22 06:26:39.000000000 +0530
+++ b/drivers/net/pasemi_mac.c	2007-09-22 13:03:04.000000000 +0530
@@ -85,11 +85,6 @@ MODULE_PARM_DESC(debug, "PA Semi MAC bit
 
 static struct pasdma_status *dma_status;
 
-static unsigned int read_iob_reg(struct pasemi_mac *mac, unsigned int reg)
-{
-	return in_le32(mac->iob_regs+reg);
-}
-
 static void write_iob_reg(struct pasemi_mac *mac, unsigned int reg,
 			  unsigned int val)
 {
@@ -530,8 +525,8 @@ static int pasemi_mac_clean_rx(struct pa
 		} else
 			skb->ip_summed = CHECKSUM_NONE;
 
-		dev->stats.rx_bytes += len;
-		dev->stats.rx_packets++;
+		mac->netdev->stats.rx_bytes += len;
+		mac->netdev->stats.rx_packets++;
 
 		skb->protocol = eth_type_trans(skb, mac->netdev);
 		netif_receive_skb(skb);
