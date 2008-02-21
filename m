From: "Magnus Damm" <magnus.damm@gmail.com>
Subject: Re: [PATCH 01/04] smc91x: pass along private data
Date: Thu, 21 Feb 2008 11:14:51 +0900
Message-ID: <aec7e5c30802201814j1f0ab232i60a97c53121fc3b6@mail.gmail.com>
References: <20080220095740.22645.36783.sendpatchset@clockwork.opensource.se>
	 <20080220095751.22645.15949.sendpatchset@clockwork.opensource.se>
	 <alpine.LFD.1.00.0802201037070.2732@xanadu.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, lethal@linux-sh.org,
	akpm@linux-foundation.org
To: "Nicolas Pitre" <nico@cam.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ag-out-0708.google.com ([72.14.246.242]:37605 "EHLO
	ag-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750695AbYBUCOx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Feb 2008 21:14:53 -0500
Received: by ag-out-0708.google.com with SMTP id 33so4907006agc.1
        for <netdev@vger.kernel.org>; Wed, 20 Feb 2008 18:14:52 -0800 (PST)
In-Reply-To: <alpine.LFD.1.00.0802201037070.2732@xanadu.home>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 21, 2008 at 12:42 AM, Nicolas Pitre <nico@cam.org> wrote:
> On Wed, 20 Feb 2008, Magnus Damm wrote:
>
>  > Pass a private data pointer to macros and functions. This makes it easy
>  > to later on make run time decisions. This patch does not change any logic.
>  > These changes should be optimized away during compilation.
>  >
>  > Signed-off-by: Magnus Damm <damm@igel.co.jp>
>  > ---
>
> > --- 0001/drivers/net/smc91x.c
>  > +++ work/drivers/net/smc91x.c 2008-02-20 16:52:48.000000000 +0900
>  > @@ -220,23 +220,23 @@ static void PRINT_PKT(u_char *buf, int l
>  >
>  >
>  >  /* this enables an interrupt in the interrupt mask register */
>  > -#define SMC_ENABLE_INT(x) do {                                               \
>  > +#define SMC_ENABLE_INT(priv, x) do {                                 \
>  >       unsigned char mask;                                             \
>  > -     spin_lock_irq(&lp->lock);                                       \
>  > -     mask = SMC_GET_INT_MASK();                                      \
>  > +     spin_lock_irq(&priv->lock);                                     \
>  > +     mask = SMC_GET_INT_MASK(priv);                                  \
>
>  Since "lp" is already used all over the place, could you simply use "lp"
>  for the macro argument name as well instead of "priv"?  This will make
>  the code more uniform and reduce the patch size.

I used the name "priv" instead of "lp" intentionally to make sure I
got compile errors if I missed something. Some variables like "ioaddr"
are today not passed as arguments to the macros but simply assumed to
be present as local variables. I wanted to avoid using the local "lp"
variable by mistake. So the "priv" name is actually a feature. =)

I'd be happy to rewrite the patch to use "lp" though, but I have to
confess that I don't see the point in redoing it. Anyway, please let
me know what you prefer.

Thank you.

/ magnus
