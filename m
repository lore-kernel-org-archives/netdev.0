From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH 2/2] route: Remove redirect_genid
Date: Tue, 6 Mar 2012 09:06:22 +0100
Message-ID: <20120306080622.GE15404@secunet.com>
References: <20120301062159.GB15404@secunet.com>
 <20120301062316.GD15404@secunet.com>
 <20120304.215505.1141896485416671142.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: timo.teras@iki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:44126 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758399Ab2CFIG3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2012 03:06:29 -0500
Content-Disposition: inline
In-Reply-To: <20120304.215505.1141896485416671142.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 04, 2012 at 09:55:05PM -0500, David Miller wrote:
> From: Steffen Klassert <steffen.klassert@secunet.com>
> Date: Thu, 1 Mar 2012 07:23:16 +0100
> 
> >  				peer = rt->peer;
> > -				if (peer) {
> > -					if (peer->redirect_learned.a4 != new_gw ||
> > -					    peer->redirect_genid != redirect_genid) {
> > -						peer->redirect_learned.a4 = new_gw;
> > -						peer->redirect_genid = redirect_genid;
> > -						atomic_inc(&__rt_peer_genid);
> > -					}
> > -					check_peer_redir(&rt->dst, peer);
> > +				if (peer && peer->redirect_learned.a4 != new_gw) {
> > +					peer->redirect_learned.a4 = new_gw;
> > +					atomic_inc(&__rt_peer_genid);
> >  				}
> > +				check_peer_redir(&rt->dst, peer);
> >  			}
> 
> If peer is NULL you cannot call check_peer_redir() because it assumes
> that the passed in peer is non-NULL and dereferences it unconditionally.
> 

Ugh, indeed. I'll fix it and resend the patchset.
Thanks for the review!
