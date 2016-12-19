From: "Niklas =?iso-8859-1?Q?S=F6derlund?=" <niklas.soderlund@ragnatech.se>
Subject: Re: [PATCHv2 1/5] sh_eth: add generic wake-on-lan support via magic
 packet
Date: Mon, 19 Dec 2016 17:41:59 +0100
Message-ID: <20161219164159.GF21006@bigcity.dyn.berto.se>
References: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
 <20161212160931.6478-2-niklas.soderlund+renesas@ragnatech.se>
 <079800f0-2e80-7a0b-01e2-51e09f05345c@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Simon Horman <horms+renesas@verge.net.au>, netdev@vger.kernel.org,
        linux-renesas-soc@vger.kernel.org,
        Geert Uytterhoeven <geert@linux-m68k.org>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f52.google.com ([209.85.215.52]:36138 "EHLO
        mail-lf0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932519AbcLSQmC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 11:42:02 -0500
Received: by mail-lf0-f52.google.com with SMTP id t196so57982513lff.3
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 08:42:01 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <079800f0-2e80-7a0b-01e2-51e09f05345c@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Sergei,

On 2016-12-18 00:50:59 +0300, Sergei Shtylyov wrote:
> Hello!
> 
> On 12/12/2016 07:09 PM, Niklas Söderlund wrote:
> 
>    Not the complete review yet, just some superficial comments.
> 
> > Add generic functionality to support Wake-on-Lan using MagicPacket which
> 
>    LAN.
> 
> > are supported by at least a few versions of sh_eth. Only add
> > functionality for WoL, no specific sh_eth version are marked to support
> > WoL yet.
> 
> [...]
> 
> > diff --git a/drivers/net/ethernet/renesas/sh_eth.c b/drivers/net/ethernet/renesas/sh_eth.c
> > index 05b0dc5..87640b9 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.c
> > +++ b/drivers/net/ethernet/renesas/sh_eth.c
> [...]
> > @@ -3150,15 +3187,67 @@ static int sh_eth_drv_remove(struct platform_device *pdev)
> [...]
> > +static int sh_eth_wol_restore(struct net_device *ndev)
> > +{
> > +	struct sh_eth_private *mdp = netdev_priv(ndev);
> > +	int ret;
> > +
> > +	napi_enable(&mdp->napi);
> > +
> > +	/* Disable MagicPacket */
> > +	sh_eth_modify(ndev, ECMR, ECMR_PMDE, 0);
> > +
> > +	/* The device need to be reset to restore MagicPacket logic
> 
>    Needs.
> 
> [...]
> > index d050f37..4ceed00 100644
> > --- a/drivers/net/ethernet/renesas/sh_eth.h
> > +++ b/drivers/net/ethernet/renesas/sh_eth.h
> > @@ -493,6 +493,7 @@ struct sh_eth_cpu_data {
> >  	unsigned shift_rd0:1;	/* shift Rx descriptor word 0 right by 16 */
> >  	unsigned rmiimode:1;	/* EtherC has RMIIMODE register */
> >  	unsigned rtrate:1;	/* EtherC has RTRATE register */
> > +	unsigned magic:1;	/* EtherC has ECMR.PMDE and ECSR.MPD */
> 
>    After looking at the SH7734/63 manuals it became obvious that PMDE was a
> result of typo, the bit is called MPDE actually, the current name doesn't
> make sense anyway. Care to fix?

Sure, I add fixup patch to the front of this series which cleans this up 
before adding WoL support. Or would you prefer I sent a separate patch 
and have the WoL series depend on it?

> 
> MBR, Sergei
> 

-- 
Regards,
Niklas Söderlund
