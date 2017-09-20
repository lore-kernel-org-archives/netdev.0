From: rosenp@gmail.com
Subject: Re: [PATCH] bgmac: Remove all offloading features, including GRO.
Date: Wed, 20 Sep 2017 14:27:44 -0700
Message-ID: <1505942864.3451.3.camel@gmail.com>
References: <20170916002305.2794-1-rosenp@gmail.com>
         <1505522096.29839.13.camel@edumazet-glaptop3.roam.corp.google.com>
         <1505522322.3726.0.camel@gmail.com>
         <0CEBE536-2C18-4ED2-90CB-3836CEF9A70E@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Florian Fainelli <f.fainelli@gmail.com>,
        Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:34867 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751636AbdITV1r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 20 Sep 2017 17:27:47 -0400
Received: by mail-pf0-f195.google.com with SMTP id i23so1657939pfi.2
        for <netdev@vger.kernel.org>; Wed, 20 Sep 2017 14:27:47 -0700 (PDT)
In-Reply-To: <0CEBE536-2C18-4ED2-90CB-3836CEF9A70E@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Sorry for the noise. After more testing I've found out that the cause
was that I had BBR enabled on my laptop. Switching back to CUBIC fixed
the issue.

In other words, this patch is detrimental.

~67mbps - gro off
~87mbps - gro on

On Fri, 2017-09-15 at 23:04 -0700, Florian Fainelli wrote:
> On September 15, 2017 5:38:42 PM PDT, rosenp@gmail.com wrote:
> > I have not. Unfortunately I own no gigabit hardware to test this
> > on.
> > The MIPS CPU runs at 300MHz on my unit.
> > 
> 
> bgmac is used on Gigabit capable hardware, like Northstar and
> Northstar Plus, and others too, so unless you can get access to such
> HW or get confirmation from someone that your patches changes
> something, I would just drop this change and not bother. This is
> already not 100mbits/sec linerate...
> 
> > On Fri, 2017-09-15 at 17:34 -0700, Eric Dumazet wrote:
> > > On Fri, 2017-09-15 at 17:23 -0700, Rosen Penev wrote:
> > > > On a linksys E1200v1 (actually a crossflashed E1000v2), the
> > > > offloading features give no measurable benefit to speed or
> > > > latency.
> > > > Furthermore, disabling GRO actually improves iperf performance
> > > > by a
> > > > whoppimg 3mbps. Results:
> > > > 
> > > > Currently:
> > > > 
> > > > v2: Changed napi_gro_receive to netif_receive_skb. Seems to
> > > > have an
> > > > identical result.
> > > > 
> > > > Signed-off-by: Rosen Penev <rosenp@gmail.com>
> > > > ---
> > > >  drivers/net/ethernet/broadcom/bgmac.c | 2 +-
> > > >  1 file changed, 1 insertion(+), 1 deletion(-)
> > > > 
> > > > diff --git a/drivers/net/ethernet/broadcom/bgmac.c
> > > > b/drivers/net/ethernet/broadcom/bgmac.c
> > > > index 48d672b204a4..1fb0053aeee7 100644
> > > > --- a/drivers/net/ethernet/broadcom/bgmac.c
> > > > +++ b/drivers/net/ethernet/broadcom/bgmac.c
> > > > @@ -483,7 +483,7 @@ static int bgmac_dma_rx_read(struct bgmac
> > > > *bgmac, struct bgmac_dma_ring *ring,
> > > >  			skb->protocol = eth_type_trans(skb,
> > > > bgmac-
> > > > > net_dev);
> > > > 
> > > >  			bgmac->net_dev->stats.rx_bytes += len;
> > > >  			bgmac->net_dev->stats.rx_packets++;
> > > > -			napi_gro_receive(&bgmac->napi, skb);
> > > > +			netif_receive_skb(skb);
> > > >  			handled++;
> > > >  		} while (0);
> > > >  
> > > 
> > > And have you tested 1Gbit link speed ?
> > > ( Or 2.5 Gbit link speed )
> > > 
> > > If you want to disable GRO on your host, fine : you can use
> > > ethtool
> > > -K
> > > 
> > > 
> > > 
> 
> (please don't top-post)
