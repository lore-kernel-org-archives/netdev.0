From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 2.6.22-git5] via-rhine: Disable rx_copybreak on archs
 that don't allow unaligned DMA access
Date: Wed, 18 Jul 2007 18:19:32 -0700
Message-ID: <20070718181932.88809ea6.akpm@linux-foundation.org>
References: <46991FBC.5070705@alcatraz.fdf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Jeff Garzik <jeff@garzik.org>,
	Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	netdev@vger.kernel.org, linux-arch@vger.kernel.org
To: Dustin Marquess <jailbird@alcatraz.dnsalias.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:43231 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1762047AbXGSBUA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2007 21:20:00 -0400
In-Reply-To: <46991FBC.5070705@alcatraz.fdf.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


(mailing lsits and cc's added - I trust that's OK)

(Please always cc mailing list(s) on patches)

On Sat, 14 Jul 2007 14:10:52 -0500
Dustin Marquess <jailbird@alcatraz.dnsalias.net> wrote:

> From: Dustin Marquess <jailbird@alcatraz.fdf.net>
> 
> Patch to disable the rx_copybreak feature on hardware architectures that
> don't allow unaligned DMA access.
> 
> #ifdef code taken from tulip_core.c.  Problem pointed out by Ivan
> Kokshaysky.
> 
> Signed-off-by: Dustin Marquess <jailbird@alcatraz.fdf.net>
> ---
> 
> diff -uprN a/drivers/net/via-rhine.c b/drivers/net/via-rhine.c
> --- a/drivers/net/via-rhine.c   2007-07-14 13:51:18.475341321 -0500
> +++ b/drivers/net/via-rhine.c   2007-07-14 13:56:40.684678999 -0500
> @@ -42,7 +42,13 @@ static int max_interrupt_work = 20;
> 
>   /* Set the copy breakpoint for the copy-only-tiny-frames scheme.
>      Setting to > 1518 effectively disables this feature. */
> +#if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
> +       || defined(CONFIG_SPARC) || defined(__ia64__) \
> +       || defined(__sh__) || defined(__mips__)
> +static int rx_copybreak = 1518;
> +#else
>   static int rx_copybreak;
> +#endif

I guess the patch makes sense, but boy that conditional does suck.

It would be much better to go into each of those architecture's
arch/foo/Kconfig and define a new CONFIG_NO_UNALIGNED_DMA or whatever, and
to then use that config variable here, in tulip_core.c and wherever else
we're doing this.

