From: "fugang.duan@freescale.com" <fugang.duan@freescale.com>
Subject: RE: [PATCH] net: fec: fix receive VLAN CTAG HW acceleration issue
Date: Tue, 10 Mar 2015 11:13:22 +0000
Message-ID: <BY2PR03MB377A5CA16D09062CE761F0CF5180@BY2PR03MB377.namprd03.prod.outlook.com>
References: <1425983442-21302-1-git-send-email-b38611@freescale.com>
 <20150310110452.GA22614@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"kernel@pengutronix.de" <kernel@pengutronix.de>
To: Michael Grzeschik <mgr@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn1on0144.outbound.protection.outlook.com ([157.56.110.144]:41504
	"EHLO na01-bn1-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750848AbbCJLNZ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 07:13:25 -0400
In-Reply-To: <20150310110452.GA22614@pengutronix.de>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Michael Grzeschik <mgr@pengutronix.de> Sent: Tuesday, March 10, 2015 7:05 PM
> To: Duan Fugang-B38611
> Cc: davem@davemloft.net; netdev@vger.kernel.org; kernel@pengutronix.de
> Subject: Re: [PATCH] net: fec: fix receive VLAN CTAG HW acceleration
> issue
> 
> On Tue, Mar 10, 2015 at 06:30:42PM +0800, Fugang Duan wrote:
> > The current driver support receive VLAN CTAG HW acceleration feature
> > (NETIF_F_HW_VLAN_CTAG_RX) through software simulation. There calls the
> > api .skb_copy_to_linear_data_offset() to skip the VLAN tag, but there
> > have overlap between the two memory data point range. The patch just
> > fix the issue.
> >
> > Reported-by: Michael Grzeschik <m.grzeschik@pengutronix.de>
> > Signed-off-by: Fugang Duan <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c |    4 +++-
> >  1 files changed, 3 insertions(+), 1 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 9bb6220..c9b1dbb 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -1475,12 +1475,14 @@ fec_enet_rx_queue(struct net_device *ndev, int
> budget, u16 queue_id)
> >  			/* Push and remove the vlan tag */
> >  			struct vlan_hdr *vlan_header =
> >  					(struct vlan_hdr *) (data + ETH_HLEN);
> > +			unsigned char eth_hdr[12];
> >  			vlan_tag = ntohs(vlan_header->h_vlan_TCI);
> >
> >  			vlan_packet_rcvd = true;
> >
> > +			memcpy(eth_hdr, data, 2 * ETH_ALEN);
> >  			skb_copy_to_linear_data_offset(skb, VLAN_HLEN,
> > -						       data, (2 * ETH_ALEN));
> > +						       eth_hdr, (2 * ETH_ALEN));
> >  			skb_pull(skb, VLAN_HLEN);
> >  		}
> >
> > --
> > 1.7.8
> 
> why not just use memmove instead of the skb_copy_to_linear_data_offset?
> 
> memmove(skb->data + VLAN_HLEN, data, (2 * ETH_ALEN));
> 
> Michael


Good suggestion. Thanks. 

Regards,
Andy
