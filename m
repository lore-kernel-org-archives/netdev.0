From: Duan Fugang-B38611 <B38611@freescale.com>
Subject: RE: [PATCH] net: fec: add the initial to set the physical mac
 address
Date: Wed, 11 Sep 2013 01:15:32 +0000
Message-ID: <9848F2DB572E5649BA045B288BE08FBE016ACCD8@039-SN2MPN1-023.039d.mgd.msft.net>
References: <1377170269-8988-1-git-send-email-B38611@freescale.com>
 <CAOJe8K2eH+6Eg0vOnOFwNsy9-TyxBJwYDCTDbLcbB3yu42OW1w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Li Frank-B20596 <B20596@freescale.com>,
	Zhou Luwei-B45643 <B45643@freescale.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"shawn.guo@linaro.org" <shawn.guo@linaro.org>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	Estevam Fabio-R49496 <r49496@freescale.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>
To: Denis Kirjanov <kda@linux-powerpc.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [213.199.154.251] ([213.199.154.251]:28125 "EHLO
	db9outboundpool.messaging.microsoft.com" rhost-flags-FAIL-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753510Ab3IKBRI convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Sep 2013 21:17:08 -0400
In-Reply-To: <CAOJe8K2eH+6Eg0vOnOFwNsy9-TyxBJwYDCTDbLcbB3yu42OW1w@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Denis Kirjanov [mailto:kda@linux-powerpc.org]
Data: Tuesday, September 10, 2013 10:19 PM

> To: Duan Fugang-B38611
> Cc: Li Frank-B20596; Zhou Luwei-B45643; davem@davemloft.net;
> netdev@vger.kernel.org; shawn.guo@linaro.org; bhutchings@solarflare.com;
> Estevam Fabio-R49496; stephen@networkplumber.org
> Subject: Re: [PATCH] net: fec: add the initial to set the physical mac
> address
> 
> On 8/22/13, Fugang Duan <B38611@freescale.com> wrote:
> > For imx6slx evk platform, the fec driver cannot work since there have
> > no valid mac address set in physical mac registers.
> >
> > For imx serial platform, fec/enet IPs both need the physical MAC
> > address initial, otherwise it cannot work.
> >
> > After acquiring the valid MAC address from devices tree/pfuse/ kernel
> > command line/random mac address, and then set it to the physical MAC
> > address registers.
> >
> > Signed-off-by: Fugang Duan  <B38611@freescale.com>
> > ---
> >  drivers/net/ethernet/freescale/fec_main.c |    9 ++++++---
> >  1 files changed, 6 insertions(+), 3 deletions(-)
> >
> > diff --git a/drivers/net/ethernet/freescale/fec_main.c
> > b/drivers/net/ethernet/freescale/fec_main.c
> > index 4349a9e..9b5e08c 100644
> > --- a/drivers/net/ethernet/freescale/fec_main.c
> > +++ b/drivers/net/ethernet/freescale/fec_main.c
> > @@ -1867,10 +1867,12 @@ fec_set_mac_address(struct net_device *ndev,
> > void
> > *p)
> >  	struct fec_enet_private *fep = netdev_priv(ndev);
> >  	struct sockaddr *addr = p;
> >
> > -	if (!is_valid_ether_addr(addr->sa_data))
> > -		return -EADDRNOTAVAIL;
> > +	if (p) {
> 
> I don't see how the p pointer can be NULL...

As below, fec_enet_init() function calls fec_set_mac_address(ndev, NULL).

> 
> > +		if (!is_valid_ether_addr(addr->sa_data))
> > +			return -EADDRNOTAVAIL;
> >
> > -	memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> > +		memcpy(ndev->dev_addr, addr->sa_data, ndev->addr_len);
> > +	}
> >
> >  	writel(ndev->dev_addr[3] | (ndev->dev_addr[2] << 8) |
> >  		(ndev->dev_addr[1] << 16) | (ndev->dev_addr[0] << 24), @@ -
> 1969,6
> > +1971,7 @@ static int fec_enet_init(struct net_device *ndev)
> >
> >  	/* Get the Ethernet address */
> >  	fec_get_mac(ndev);
> > +	fec_set_mac_address(ndev, NULL);
> >
> >  	/* Set receive and transmit descriptor base. */
> >  	fep->rx_bd_base = cbd_base;
