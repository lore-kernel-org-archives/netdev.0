From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: skge: Add DMA mask quirk for Marvell 88E8001 on ASUS P5NSLI
 motherboard.
Date: Mon, 8 Oct 2012 09:16:08 -0700
Message-ID: <20121008091608.0b03befa@nehalam.linuxnetplumber.net>
References: <50711961.1010101@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Graham Gower <graham.gower@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43707 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751589Ab2JHQQs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Oct 2012 12:16:48 -0400
In-Reply-To: <50711961.1010101@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 07 Oct 2012 16:25:45 +1030
Graham Gower <graham.gower@gmail.com> wrote:

> Marvell 88E8001 on an ASUS P5NSLI motherboard is unable to send/receive
> packets on a system with >4gb ram unless a 32bit DMA mask is used.
> 
> This issue has been around for years and a fix was sent 3.5 years ago, but
> there was some debate as to whether it should instead be fixed as a PCI quirk.
> http://www.spinics.net/lists/netdev/msg88670.html
> 
> However, 18 months later a similar workaround was introduced for another
> chipset exhibiting the same problem.
> http://www.spinics.net/lists/netdev/msg142287.html
> 
> Signed-off-by: Graham Gower <graham.gower@gmail.com>
> 
> --- skge.c.bak	2012-10-07 13:00:56.000000000 +1030
> +++ skge.c	2012-10-07 13:26:03.000000000 +1030
> @@ -4143,6 +4143,13 @@
>   			DMI_MATCH(DMI_BOARD_NAME, "nForce"),
>   		},
>   	},
> +	{
> +		.ident = "ASUS P5NSLI",
> +		.matches = {
> +			DMI_MATCH(DMI_BOARD_VENDOR, "ASUSTeK Computer INC."),
> +			DMI_MATCH(DMI_BOARD_NAME, "P5NSLI")
> +		},
> +	},
>   	{}
>   };
>   

This fix is fine, but like Jan said it needs to be based at the
right place in the filesystem tree for inclusion.

I wonder if it would be a good idea to add a way to automatically
check for this quirk using the debug registers on the chip which allow
peeking. Using the test registers B3_RAM_DATA_LO/B3_RAM_DATA_HI.

The problem is that might introduce worse problems if it causes
DMA access to non-existent memory and trying to recover from the fault.
