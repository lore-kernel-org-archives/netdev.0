From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [Bridge] Bridging on broken Broadcom hardware.
Date: Wed, 18 Feb 2004 16:16:11 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040218161611.6365c3bf@dell_ss3.pdx.osdl.net>
References: <1077146945.3779.17.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, sjolly@foursticks.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Paul Schulz <pschulz@foursticks.com>
In-Reply-To: <1077146945.3779.17.camel@localhost>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This looks like a network driver not bridging problem, so forwarding to
the netdev list.

On Thu, 19 Feb 2004 09:59:05 +1030
Paul Schulz <pschulz@foursticks.com> wrote:

> Greetings (first post to the list, with patch)...
> 
> The following patch is required to allow bridging to occur on an
> IBM x305 (1RU server) - with the tg3 module.  
> (This has been posted to the kernel-developers mailing list.)
> 
> Background:
>   - The Dual Broadcom NICs in the IBM x305 have a broken checksum
>     routine which wants to calculate the checksum the ethernet
>     packet where the 'source' IP address is the IP address 
>     of the sending interface.
>     This breaks bridging! (Upstream hosts see an invalid checksum 
>     and drop the packet.)
> 
>   - I have heard of other issues with Broadcom NICs not
>     working with IPv6 and broadcast/multicast which could be 
>     related.
>     
> I would like to get these results and the fix verified, as it will
> effect any hosts using this chipset. Does anyone have any pointers?
> 
> Paul Schulz <pschulz@foursticks.com>
> 
> --------------------------------------------------------------------
> diff -Naur linux-2.4.20/drivers/net/tg3.c linux-2.4.20-np/drivers/net/tg3.c
> --- linux-2.4.20/drivers/net/tg3.c	Fri Nov 29 10:23:14 2002
> +++ linux-2.4.20-np/drivers/net/tg3.c	Thu Jan 23 14:46:54 2003
> @@ -6161,6 +6161,11 @@
>  	if (tp->pci_chip_rev_id == CHIPREV_ID_5700_B0)
>  		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
>  
> +	/* 5703 A2 have issues with checksumming too. (sarah) */
> +	if (tp->pci_chip_rev_id == CHIPREV_ID_5703_A2)
> +		tp->tg3_flags |= TG3_FLAG_BROKEN_CHECKSUMS;
> +
>  	/* Regardless of whether checksums work or not, we configure
>  	 * the StrongARM chips to not compute the pseudo header checksums
>  	 * in either direction.  Because of the way Linux checksum support
> 
> 
> 
> 


-- 
Stephen Hemminger 		mailto:shemminger@osdl.org
Open Source Development Lab	http://developer.osdl.org/shemminger
