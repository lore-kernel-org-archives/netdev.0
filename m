From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net 2/2] ip_tunnel: Add fallback tunnels to the hash lists
Date: Thu, 26 Sep 2013 10:13:44 +0200
Message-ID: <20130926081344.GA7660@secunet.com>
References: <20130925055418.GV7660@secunet.com>
 <20130925055519.GW7660@secunet.com>
 <CALnjE+rrm3Vzov4sUjBfEKHwzRb6MfTRhkA_B96yuNGpgFgiCg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Pravin Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:32910 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755226Ab3IZINr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Sep 2013 04:13:47 -0400
Content-Disposition: inline
In-Reply-To: <CALnjE+rrm3Vzov4sUjBfEKHwzRb6MfTRhkA_B96yuNGpgFgiCg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 25, 2013 at 09:03:11AM -0700, Pravin Shelar wrote:
> On Tue, Sep 24, 2013 at 10:55 PM, Steffen Klassert
> <steffen.klassert@secunet.com> wrote:
> > Currently we can not update the tunnel parameters of
> > the fallback tunnels because we don't find them in the
> > hash lists. Fix this by adding them on initialization.
> >
> > Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
> > ---
> >  net/ipv4/ip_tunnel.c |    4 +++-
> >  1 file changed, 3 insertions(+), 1 deletion(-)
> >
> > diff --git a/net/ipv4/ip_tunnel.c b/net/ipv4/ip_tunnel.c
> > index b8ce640..f2348f2 100644
> > --- a/net/ipv4/ip_tunnel.c
> > +++ b/net/ipv4/ip_tunnel.c
> > @@ -853,8 +853,10 @@ int ip_tunnel_init_net(struct net *net, int ip_tnl_net_id,
> >         /* FB netdevice is special: we have one, and only one per netns.
> >          * Allowing to move it to another netns is clearly unsafe.
> >          */
> > -       if (!IS_ERR(itn->fb_tunnel_dev))
> > +       if (!IS_ERR(itn->fb_tunnel_dev)) {
> >                 itn->fb_tunnel_dev->features |= NETIF_F_NETNS_LOCAL;
> > +               ip_tunnel_add(itn, netdev_priv(itn->fb_tunnel_dev));
> > +       }
> >         rtnl_unlock();
> >
> fallback tunnel s not required to be in hash table, Its is returned if
> none of hashed tunnels are matched, ref ip_tunnel_lookup().
> Can you post command to reproduce this issue?
> 

Something like

ip tunnel change tunl0 mode ipip remote 0.0.0.0 local 0.0.0.0 ttl 0 tos 1

worked until v3.9 and stopped working with v3.10.
