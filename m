From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH 04/39] mv643xx_eth: get rid of individual port config register bit defines
Date: Fri, 6 Jun 2008 08:58:39 +0200
Message-ID: <20080606065839.GA5100@xi.wantstofly.org>
References: <1212490974-23719-1-git-send-email-buytenh@wantstofly.org> <1212490974-23719-5-git-send-email-buytenh@wantstofly.org> <20080605110734.GB1059@farnsworth.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Dale Farnsworth <dale@farnsworth.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56225 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753977AbYFFG7N (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Jun 2008 02:59:13 -0400
Content-Disposition: inline
In-Reply-To: <20080605110734.GB1059@farnsworth.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jun 05, 2008 at 04:07:34AM -0700, Dale Farnsworth wrote:

> > The mv643xx_eth driver only ever changes bit 0 of the port config
> > register at run time, the rest of the register bits are fixed (and
> > always zero).  Document the meaning of the chosen default value,
> > and get rid of all the defines for each of the individual bits.
> > 
> > Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>
> > ---
> >  drivers/net/mv643xx_eth.c |   44 +++++++-------------------------------------
> >  1 files changed, 7 insertions(+), 37 deletions(-)
> > 
> > diff --git a/drivers/net/mv643xx_eth.c b/drivers/net/mv643xx_eth.c
> > index 9a9218f..38ba365 100644
> > --- a/drivers/net/mv643xx_eth.c
> > +++ b/drivers/net/mv643xx_eth.c
> > @@ -109,39 +109,6 @@ static char mv643xx_driver_version[] = "1.0";
> >  #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
> >  #define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
> >  
> > -/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
> > -#define UNICAST_NORMAL_MODE		(0 << 0)
> > -#define UNICAST_PROMISCUOUS_MODE	(1 << 0)
> > -#define DEFAULT_RX_QUEUE(queue)		((queue) << 1)
> > -#define DEFAULT_RX_ARP_QUEUE(queue)	((queue) << 4)
> > -#define RECEIVE_BC_IF_NOT_IP_OR_ARP	(0 << 7)
> > -#define REJECT_BC_IF_NOT_IP_OR_ARP	(1 << 7)
> > -#define RECEIVE_BC_IF_IP		(0 << 8)
> > -#define REJECT_BC_IF_IP			(1 << 8)
> > -#define RECEIVE_BC_IF_ARP		(0 << 9)
> > -#define REJECT_BC_IF_ARP		(1 << 9)
> > -#define TX_AM_NO_UPDATE_ERROR_SUMMARY	(1 << 12)
> > -#define CAPTURE_TCP_FRAMES_DIS		(0 << 14)
> > -#define CAPTURE_TCP_FRAMES_EN		(1 << 14)
> > -#define CAPTURE_UDP_FRAMES_DIS		(0 << 15)
> > -#define CAPTURE_UDP_FRAMES_EN		(1 << 15)
> > -#define DEFAULT_RX_TCP_QUEUE(queue)	((queue) << 16)
> > -#define DEFAULT_RX_UDP_QUEUE(queue)	((queue) << 19)
> > -#define DEFAULT_RX_BPDU_QUEUE(queue)	((queue) << 22)
> > -
> > -#define PORT_CONFIG_DEFAULT_VALUE			\
> > -		UNICAST_NORMAL_MODE		|	\
> > -		DEFAULT_RX_QUEUE(0)		|	\
> > -		DEFAULT_RX_ARP_QUEUE(0)		|	\
> > -		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
> > -		RECEIVE_BC_IF_IP		|	\
> > -		RECEIVE_BC_IF_ARP		|	\
> > -		CAPTURE_TCP_FRAMES_DIS		|	\
> > -		CAPTURE_UDP_FRAMES_DIS		|	\
> > -		DEFAULT_RX_TCP_QUEUE(0)		|	\
> > -		DEFAULT_RX_UDP_QUEUE(0)		|	\
> > -		DEFAULT_RX_BPDU_QUEUE(0)
> > -
> >  /* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
> >  #define CLASSIFY_EN				(1 << 0)
> >  #define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
> > @@ -1802,9 +1769,9 @@ static void mv643xx_eth_set_rx_mode(struct net_device *dev)
> >  
> >  	config_reg = rdl(mp, PORT_CONFIG(mp->port_num));
> >  	if (dev->flags & IFF_PROMISC)
> > -		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
> > +		config_reg |= 0x00000001;
> 
> Except for the stupid cast, I think the meaning was clearer with the
> define.

Right, I got a bit carried away. :-)  How about this instead:



From: Lennert Buytenhek <buytenh@wantstofly.org>
Date: Sun Jun  1 01:22:06 CEST 2008
Subject: mv643xx_eth: get rid of individual port config register bit defines

The mv643xx_eth driver only ever changes bit 0 of the port config
register at run time, the rest of the register bits are fixed (and
always zero).  Document the meaning of the chosen default value,
and get rid of all the defines for each of the individual bits.

Signed-off-by: Lennert Buytenhek <buytenh@marvell.com>

Index: linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
===================================================================
--- linux-2.6.26-rc5.orig/drivers/net/mv643xx_eth.c
+++ linux-2.6.26-rc5/drivers/net/mv643xx_eth.c
@@ -88,6 +88,7 @@ static char mv643xx_driver_version[] = "
  * Per-port registers.
  */
 #define PORT_CONFIG(p)			(0x0400 + ((p) << 10))
+#define  UNICAST_PROMISCUOUS_MODE	0x00000001
 #define PORT_CONFIG_EXT(p)		(0x0404 + ((p) << 10))
 #define MAC_ADDR_LOW(p)			(0x0414 + ((p) << 10))
 #define MAC_ADDR_HIGH(p)		(0x0418 + ((p) << 10))
@@ -109,39 +110,6 @@ static char mv643xx_driver_version[] = "
 #define OTHER_MCAST_TABLE(p)		(0x1500 + ((p) << 10))
 #define UNICAST_TABLE(p)		(0x1600 + ((p) << 10))
 
-/* These macros describe Ethernet Port configuration reg (Px_cR) bits */
-#define UNICAST_NORMAL_MODE		(0 << 0)
-#define UNICAST_PROMISCUOUS_MODE	(1 << 0)
-#define DEFAULT_RX_QUEUE(queue)		((queue) << 1)
-#define DEFAULT_RX_ARP_QUEUE(queue)	((queue) << 4)
-#define RECEIVE_BC_IF_NOT_IP_OR_ARP	(0 << 7)
-#define REJECT_BC_IF_NOT_IP_OR_ARP	(1 << 7)
-#define RECEIVE_BC_IF_IP		(0 << 8)
-#define REJECT_BC_IF_IP			(1 << 8)
-#define RECEIVE_BC_IF_ARP		(0 << 9)
-#define REJECT_BC_IF_ARP		(1 << 9)
-#define TX_AM_NO_UPDATE_ERROR_SUMMARY	(1 << 12)
-#define CAPTURE_TCP_FRAMES_DIS		(0 << 14)
-#define CAPTURE_TCP_FRAMES_EN		(1 << 14)
-#define CAPTURE_UDP_FRAMES_DIS		(0 << 15)
-#define CAPTURE_UDP_FRAMES_EN		(1 << 15)
-#define DEFAULT_RX_TCP_QUEUE(queue)	((queue) << 16)
-#define DEFAULT_RX_UDP_QUEUE(queue)	((queue) << 19)
-#define DEFAULT_RX_BPDU_QUEUE(queue)	((queue) << 22)
-
-#define PORT_CONFIG_DEFAULT_VALUE			\
-		UNICAST_NORMAL_MODE		|	\
-		DEFAULT_RX_QUEUE(0)		|	\
-		DEFAULT_RX_ARP_QUEUE(0)		|	\
-		RECEIVE_BC_IF_NOT_IP_OR_ARP	|	\
-		RECEIVE_BC_IF_IP		|	\
-		RECEIVE_BC_IF_ARP		|	\
-		CAPTURE_TCP_FRAMES_DIS		|	\
-		CAPTURE_UDP_FRAMES_DIS		|	\
-		DEFAULT_RX_TCP_QUEUE(0)		|	\
-		DEFAULT_RX_UDP_QUEUE(0)		|	\
-		DEFAULT_RX_BPDU_QUEUE(0)
-
 /* These macros describe Ethernet Port configuration extend reg (Px_cXR) bits*/
 #define CLASSIFY_EN				(1 << 0)
 #define SPAN_BPDU_PACKETS_AS_NORMAL		(0 << 1)
@@ -1802,9 +1770,9 @@ static void mv643xx_eth_set_rx_mode(stru
 
 	config_reg = rdl(mp, PORT_CONFIG(mp->port_num));
 	if (dev->flags & IFF_PROMISC)
-		config_reg |= (u32) UNICAST_PROMISCUOUS_MODE;
+		config_reg |= UNICAST_PROMISCUOUS_MODE;
 	else
-		config_reg &= ~(u32) UNICAST_PROMISCUOUS_MODE;
+		config_reg &= ~UNICAST_PROMISCUOUS_MODE;
 	wrl(mp, PORT_CONFIG(mp->port_num), config_reg);
 
 	eth_port_set_multicast_list(dev);
@@ -2226,8 +2194,11 @@ static void eth_port_start(struct net_de
 	/* Add the assigned Ethernet address to the port's address table */
 	eth_port_uc_addr_set(mp, dev->dev_addr);
 
-	/* Assign port configuration and command. */
-	wrl(mp, PORT_CONFIG(port_num), PORT_CONFIG_DEFAULT_VALUE);
+	/*
+	 * Receive all unmatched unicast, TCP, UDP, BPDU and broadcast
+	 * frames to RX queue #0.
+	 */
+	wrl(mp, PORT_CONFIG(port_num), 0x00000000);
 
 	wrl(mp, PORT_CONFIG_EXT(port_num), PORT_CONFIG_EXTEND_DEFAULT_VALUE);
