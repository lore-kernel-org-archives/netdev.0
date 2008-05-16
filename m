From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: linux-next: Tree for May 14
Date: Fri, 16 May 2008 09:12:51 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0805160911400.22059@anakin>
References: <20080514170106.3cbcb201.sfr@canb.auug.org.au>
 <Pine.LNX.4.64.0805142237240.11631@anakin> <20080514135008.60e5df96.randy.dunlap@oracle.com>
 <20080514210447.GK20457@bakeyournoodle.com> <20080515010550.GL20457@bakeyournoodle.com>
 <Pine.LNX.4.64.0805150914220.11631@anakin> <20080516021009.GS20457@bakeyournoodle.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Stephen Rothwell <sfr@canb.auug.org.au>,
	linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Jeff Garzik <jgarzik@redhat.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Linux/m68k <linux-m68k@vger.kernel.org>
To: Tony Breeds <tony@bakeyournoodle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from harold.telenet-ops.be ([195.130.133.65]:39500 "EHLO
	harold.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751740AbYEPHMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 May 2008 03:12:55 -0400
In-Reply-To: <20080516021009.GS20457@bakeyournoodle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 16 May 2008, Tony Breeds wrote:
> On Thu, May 15, 2008 at 09:17:15AM +0200, Geert Uytterhoeven wrote:
> > Technically, it could also happen on PPC (APUS), but all APUS support got
> > removed a few months ago.
> > So maybe CONFIG_ZORRO is more appropriate?
> 
> Well as it turns out it can happen in a few other plcaes (the same error
> is visible on sh aswell:
> 	http://kisskb.ellerman.id.au/kisskb/buildresult/27769/ )
> 
> Below is a new fix. Thoughts?.

Looks OK to me!

> --- a/drivers/net/lib8390.c
> +++ b/drivers/net/lib8390.c
> @@ -553,6 +553,9 @@ static void __ei_poll(struct net_device *dev)
>  static void ei_tx_err(struct net_device *dev)
>  {
>  	unsigned long e8390_base = dev->base_addr;
> +	/* ei_local is used on some platforms via the EI_SHIFT macro */
> +	struct ei_device *ei_local __maybe_unused =
> +		(struct ei_device *) netdev_priv(dev);
                ^^^^^^^^^^^^^^^^^^^^
But please don't reintroduce the casts. netdev_priv() returns a void *.

>  	unsigned char txsr = ei_inb_p(e8390_base+EN0_TSR);
>  	unsigned char tx_was_aborted = txsr & (ENTSR_ABT+ENTSR_FU);
>  
> @@ -815,6 +818,9 @@ static void ei_rx_overrun(struct net_device *dev)
>  {
>  	unsigned long e8390_base = dev->base_addr;
>  	unsigned char was_txing, must_resend = 0;
> +	/* ei_local is used on some platforms via the EI_SHIFT macro */
> +	struct ei_device *ei_local __maybe_unused =
> +		(struct ei_device *) netdev_priv(dev);
                ^^^^^^^^^^^^^^^^^^^^
Gr{oetje,eeting}s,

						Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-m68k.org

In personal conversations with technical people, I call myself a hacker. But
when I'm talking to journalists I just say "programmer" or something like that.
							    -- Linus Torvalds
