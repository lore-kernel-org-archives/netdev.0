From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [PATCH 2/2] ip_tunnel: Add missing validation of encap type to
 ip_tunnel_encap_setup()
Date: Tue, 16 Dec 2014 20:50:40 +0000
Message-ID: <20141216205040.GA28766@casper.infradead.org>
References: <cover.1418759998.git.tgraf@suug.ch>
 <dd70de766b1111fdcb4794f6d671e4eca5053730.1418759998.git.tgraf@suug.ch>
 <CA+mtBx_364iHXxLkA=Ytb=34_2zEy9-3hqfOdt96Ckhm8NwFiQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:49788 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750882AbaLPUul (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Dec 2014 15:50:41 -0500
Content-Disposition: inline
In-Reply-To: <CA+mtBx_364iHXxLkA=Ytb=34_2zEy9-3hqfOdt96Ckhm8NwFiQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/16/14 at 12:23pm, Tom Herbert wrote:
> On Tue, Dec 16, 2014 at 12:05 PM, Thomas Graf <tgraf@suug.ch> wrote:
> > The encap->type comes straight from Netlink. Validate it against
> > max supported encap types just like ip_encap_hlen() already does.
> >
> > Fixes: a8c5f9 ("ip_tunnel: Ops registration for secondary encap (fou, gue)")
> > Signed-off-by: Thomas Graf <tgraf@suug.ch>
> > ---
> >  net/ipv4/ip_tunnel.c | 3 +++
> >  1 file changed, 3 insertions(+)
> >
> > diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> > index 2f498f8..d3e4479 100644
> > --- a/net/ipv4/ip_tunnel.c
> > +++ b/net/ipv4/ip_tunnel.c
> > @@ -573,6 +573,9 @@ int ip_tunnel_encap(struct sk_buff *skb, struct ip_tunnel *t,
> >         if (t->encap.type == TUNNEL_ENCAP_NONE)
> >                 return 0;
> >
> > +       if (t->encap.type >= MAX_IPTUN_ENCAP_OPS)
> > +               return -EINVAL;
> > +
> 
> I don't think this is technically needed, we should have already
> verified the type when setting up the tunnel (ip_encap_hlen).

Right, assuming that every API user always calls ip_tunnel_encap_setup()
on changelink. It's currently the case but since this is a exported
API I figured we better be safe than sorry, in particular as
ip_tunnel_encap() is called before ip_encap_hlen() on xmit.
