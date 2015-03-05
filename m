From: Ben Hutchings <ben.hutchings@codethink.co.uk>
Subject: Re: [net-next, 2/5] sh_eth: WARN on access to a register not
 implemented in a particular chip
Date: Thu, 05 Mar 2015 13:18:52 +0000
Message-ID: <1425561532.4288.34.camel@xylophone.i.decadent.org.uk>
References: <1424982854.4444.73.camel@xylophone.i.decadent.org.uk>
	 <alpine.DEB.2.10.1503050958520.8385@ayla.of.borg>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@lists.codethink.co.uk,
	Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>,
	Mitsuhiro Kimura <mitsuhiro.kimura.kc@renesas.com>,
	Yoshihiro Kaneko <ykaneko0929@gmail.com>,
	Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:45740 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751516AbbCENS6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Mar 2015 08:18:58 -0500
In-Reply-To: <alpine.DEB.2.10.1503050958520.8385@ayla.of.borg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-03-05 at 10:02 +0100, Geert Uytterhoeven wrote:
> Replying to a patchwork mbox, as I noticed this is in net-next.
> 
> On Thu, 26 Feb 2015, Ben Hutchings wrote:
> > Currently we may silently read/write a register at offset 0.  Change
> > this to WARN and then ignore the write or read-back all-ones.
> > 
> > Signed-off-by: Ben Hutchings <ben.hutchings@codethink.co.uk>
> > Acked-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> 
> While this may be a good idea for debugging...
> 
> > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > @@ -543,19 +543,29 @@ static inline void sh_eth_soft_swap(char *src, int len)
> >  #endif
> >  }
> >  
> > +#define SH_ETH_OFFSET_INVALID	((u16) ~0)
> > +
> >  static inline void sh_eth_write(struct net_device *ndev, u32 data,
> >  				int enum_index)
> >  {
> >  	struct sh_eth_private *mdp = netdev_priv(ndev);
> > +	u16 offset = mdp->reg_offset[enum_index];
> > +
> > +	if (WARN_ON(offset == SH_ETH_OFFSET_INVALID))
> > +		return;
> 
> ... adding WARN_ON() to static inline functions increases code size a lot:
> 
> $ size drivers/net/ethernet/renesas/sh_eth.o{.orig,}
>    text	   data	    bss	    dec	    hex	filename
>   23352	   1136	      0	  24488	   5fa8	drivers/net/ethernet/renesas/sh_eth.o.orig
>   27225	   1136	      0	  28361	   6ec9	drivers/net/ethernet/renesas/sh_eth.o
> $

Time to un-inline it, maybe?

Ben.
