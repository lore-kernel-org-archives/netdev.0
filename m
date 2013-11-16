From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/2] net: ipv6: af_inet6: Fix warning when CONFIG_SYSCTL=n
Date: Sat, 16 Nov 2013 19:26:00 +0100
Message-ID: <20131116182600.GB16541@order.stressinduktion.org>
References: <1384570328-21666-1-git-send-email-festevam@gmail.com> <5287B3E2.2030301@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Fabio Estevam <festevam@gmail.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Fabio Estevam <fabio.estevam@freescale.com>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:47253 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab3KPS0C (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 16 Nov 2013 13:26:02 -0500
Content-Disposition: inline
In-Reply-To: <5287B3E2.2030301@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Nov 16, 2013 at 01:05:22PM -0500, Vlad Yasevich wrote:
> On 11/15/2013 09:52 PM, Fabio Estevam wrote:
> > From: Fabio Estevam <fabio.estevam@freescale.com>
> > 
> > When CONFIG_SYSCTL=n the following build warning happens:
> > 
> > net/ipv6/af_inet6.c:710:13: warning: 'ipv6_packet_cleanup' defined but not used [-Wunused-function]
> > 
> > ipv6_packet_cleanup() is only used when CONFIG_SYSCTL=y, so protect its 
> > definition with an'ifdef CONFIG_SYSCTL'.
> > 
> > Signed-off-by: Fabio Estevam <fabio.estevam@freescale.com>
> > ---
> >  net/ipv6/af_inet6.c | 2 ++
> >  1 file changed, 2 insertions(+)
> > 
> > diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
> > index ff75313..e4ad65c 100644
> > --- a/net/ipv6/af_inet6.c
> > +++ b/net/ipv6/af_inet6.c
> > @@ -707,10 +707,12 @@ static int __init ipv6_packet_init(void)
> >  	return 0;
> >  }
> >  
> > +#ifdef CONFIG_SYSCTL
> >  static void ipv6_packet_cleanup(void)
> >  {
> >  	dev_remove_pack(&ipv6_packet_type);
> >  }
> > +#endif
> >  
> >  static int __net_init ipv6_init_mibs(struct net *net)
> >  {
> > 
> 
> NACK.  ipv6_packet_init and ipv6_packet_cleanup should in no way depend
> on sysctl.

It is only used in an error path if CONFIG_SYSCTL=y. I agree it does
look a bit odd.

Maybe just add __maybe_unused to ipv6_packet_cleanup?
