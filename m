From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
Subject: Re: Fw: [PATCH] ucc_geth: Correct fixed_link OOPS.
Date: Fri, 20 Mar 2009 21:46:13 +0100
Message-ID: <OF9395F5D9.8C7241AA-ONC125757F.00714908-C125757F.0072183A@transmode.se>
References: <OF20EA88BB.017079CD-ONC125757F.006C40A2-C125757F.006C646E@transmode.se> <20090320200740.GA32082@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: leoli@freescale.com, linuxppc-dev@ozlabs.org,
	netdev@vger.kernel.org
To: avorontsov@ru.mvista.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([213.115.205.20]:42592 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751060AbZCTUqP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Mar 2009 16:46:15 -0400
In-Reply-To: <20090320200740.GA32082@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 20/03/2009 21:07:40:
> 
> On Fri, Mar 20, 2009 at 08:43:56PM +0100, Joakim Tjernlund wrote:
> > hmm, this mail didn't seem to reach the lists. Resending
> > 
> >  Jocke
> > ----- Forwarded by Joakim Tjernlund/Transmode on 20/03/2009 20:42 
-----
> > 
> > From:
> > Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > To:
> > leoli@freescale.com, netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
> > Cc:
> > Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > Date:
> > 20/03/2009 18:01
> > Subject:
> > [PATCH] ucc_geth: Correct fixed_link OOPS.
> > 
> > 
> > 
> > fixed_link(PHY less) mode will get you an NULL
> > deference as it does not have a phy-handle.
> > Correct by using already probed information.
> > 
> > Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> > ---
> > 
> > The below fixes the problem and seems like the right thing to do.
> > Can we have this in 2.6.29?
> > 
> >  drivers/net/ucc_geth.c |   17 +----------------
> >  1 files changed, 1 insertions(+), 16 deletions(-)

[SNIP]

> 
> This effectivly breaks boards where Gianfar is using UCC's MDIO
> bus (i.e. breaks commit b1c4a9dddf09fe99b8f88252718ac5b357363dc4,
> which is the cause of fixed-link breakage, btw). And, your patch
> is line-wrapped and tabs are substituted by white spaces...

Yes, I noticed that afterwards. It is our "great" new mailsystem
that gets in the way. I really need to find another mailsystem as
Lotus/Domino gets in my way too often :(

> 
> I would suggest something along these lines (unfortunately
> right now I can't test it on real HW, only compile-tested):

Tested here, works fine for fixed-link PHYs, thanks.
I left the 
    priv->oldlink = 0;
    priv->oldspeed = 0;
    priv->oldduplex = -1;
in though. Seemed like a good idea.

Tested By: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>

 Jocke

