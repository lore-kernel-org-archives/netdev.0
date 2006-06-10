From: Sam Ravnborg <sam@ravnborg.org>
Subject: Re: [PATCH] [2.6.17-rc6] Section mismatch in drivers/net/ne.o during modpost
Date: Sat, 10 Jun 2006 22:38:00 +0200
Message-ID: <20060610203800.GC9502@mars.ravnborg.org>
References: <200606101211.k5ACBgtl029545@harpo.it.uu.se> <20060610121335.447e19f2.rdunlap@xenotime.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Mikael Pettersson <mikpe@it.uu.se>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, jgarzik <jgarzik@pobox.com>,
	akpm <akpm@osdl.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pasmtpb.tele.dk ([80.160.77.98]:16772 "EHLO pasmtp.tele.dk")
	by vger.kernel.org with ESMTP id S1030508AbWFJUiT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jun 2006 16:38:19 -0400
To: "Randy.Dunlap" <rdunlap@xenotime.net>
Content-Disposition: inline
In-Reply-To: <20060610121335.447e19f2.rdunlap@xenotime.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 
> > Not sure how serious this is; the driver seems to work fine later on.
> 
> Doesn't look serious.  init_module() is not __init, but it calls
> some __init functions and touches some __initdata.

This is the typical case with inconsistent tagging.

> BTW, I would be happy to see some consistent results from modpost
> section checking.  I don't see all of these warnings (I see only 1)
> when using gcc 3.3.6.  What gcc version are you using?
> Does that matter?  (not directed at anyone in particular)
I did not see anyone of them - strange.
I did not dig into it, but objdump -rR ne.o should tell the number of
mismatches with soem carefull checking.


> --- linux-2617-rc6.orig/drivers/net/ne.c
> +++ linux-2617-rc6/drivers/net/ne.c
> @@ -829,7 +829,7 @@ that the ne2k probe is the last 8390 bas
>  is at boot) and so the probe will get confused by any other 8390 cards.
>  ISA device autoprobes on a running machine are not recommended anyway. */
>  
> -int init_module(void)
> +int __init init_module(void)
>  {
>  	int this_dev, found = 0;

When you anyway touches the driver I suggest to name the function
<module>_init, <module>_cleanup and use module_init(), module_cleanup().

	Sam
