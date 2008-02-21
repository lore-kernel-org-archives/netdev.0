From: Nicolas Pitre <nico@cam.org>
Subject: Re: [PATCH 01/04] smc91x: pass along private data
Date: Wed, 20 Feb 2008 22:35:18 -0500 (EST)
Message-ID: <alpine.LFD.1.00.0802202229120.2732@xanadu.home>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
 <20080220095751.22645.15949.sendpatchset@clockwork.opensource.se>
 <alpine.LFD.1.00.0802201037070.2732@xanadu.home>
 <aec7e5c30802201814j1f0ab232i60a97c53121fc3b6@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: Magnus Damm <magnus.damm@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relais.videotron.ca ([24.201.245.36]:51233 "EHLO
	relais.videotron.ca" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751565AbYBUDfT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 22:35:19 -0500
Received: from xanadu.home ([66.131.194.97]) by VL-MO-MR005.ip.videotron.ca
 (Sun Java(tm) System Messaging Server 6.3-4.01 (built Aug  3 2007; 32bit))
 with ESMTP id <0JWK00F7DKMMK4G0@VL-MO-MR005.ip.videotron.ca> for
 netdev@vger.kernel.org; Wed, 20 Feb 2008 22:35:11 -0500 (EST)
In-reply-to: <aec7e5c30802201814j1f0ab232i60a97c53121fc3b6@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Feb 2008, Magnus Damm wrote:

> On Thu, Feb 21, 2008 at 12:42 AM, Nicolas Pitre <nico@cam.org> wrote:
> > On Wed, 20 Feb 2008, Magnus Damm wrote:
> >
> >  > Pass a private data pointer to macros and functions. This makes it easy
> >  > to later on make run time decisions. This patch does not change any logic.
> >  > These changes should be optimized away during compilation.
> >  >
> >  > Signed-off-by: Magnus Damm <damm@igel.co.jp>
> >  > ---
> >
> > > --- 0001/drivers/net/smc91x.c
> >  > +++ work/drivers/net/smc91x.c 2008-02-20 16:52:48.000000000 +0900
> >  > @@ -220,23 +220,23 @@ static void PRINT_PKT(u_char *buf, int l
> >  >
> >  >
> >  >  /* this enables an interrupt in the interrupt mask register */
> >  > -#define SMC_ENABLE_INT(x) do {                                               \
> >  > +#define SMC_ENABLE_INT(priv, x) do {                                 \
> >  >       unsigned char mask;                                             \
> >  > -     spin_lock_irq(&lp->lock);                                       \
> >  > -     mask = SMC_GET_INT_MASK();                                      \
> >  > +     spin_lock_irq(&priv->lock);                                     \
> >  > +     mask = SMC_GET_INT_MASK(priv);                                  \
> >
> >  Since "lp" is already used all over the place, could you simply use "lp"
> >  for the macro argument name as well instead of "priv"?  This will make
> >  the code more uniform and reduce the patch size.
> 
> I used the name "priv" instead of "lp" intentionally to make sure I
> got compile errors if I missed something. Some variables like "ioaddr"
> are today not passed as arguments to the macros but simply assumed to
> be present as local variables. I wanted to avoid using the local "lp"
> variable by mistake. So the "priv" name is actually a feature. =)

Well, you end up using the local lp variable in all cases anyway.

> I'd be happy to rewrite the patch to use "lp" though, but I have to
> confess that I don't see the point in redoing it. Anyway, please let
> me know what you prefer.

I do prefer to have lp everywhere.  But you simply have to search and 
replace "priv" with "lp" in the patch directly.  Then just applying it 
and rediffing will take care of the simplification.


Nicolas
