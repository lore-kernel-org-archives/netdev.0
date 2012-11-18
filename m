From: Jan Janssen <medhefgo@web.de>
Subject: Re: PROBLEM: freeze when resuming from suspend-to-ram
Date: Sun, 18 Nov 2012 11:28:16 +0100
Message-ID: <3791100.UEdZkjCSEi@brinja>
References: <1560844.T75lq5MbC7@brinja> <2582926.dI8WEMfVKW@brinja> <20121117192036.GA29018@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Daniele Venzano <venza@brownhat.org>, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.17.11]:64777 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751209Ab2KRK2U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Nov 2012 05:28:20 -0500
In-Reply-To: <20121117192036.GA29018@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 17 November 2012 20:20:36 Francois Romieu wrote:
> Jan Janssen <medhefgo@web.de> :
> [...]
> 
> > I'd be glad to help you with that. The bug happens with 3.6.6 and with
> > 3.7-
> > rc6. Pick one that suits you best, I can work with both.
> 
> /me slaps head.
> 
> Please try the patch below against v3.7-rc6
> 
> diff --git a/drivers/net/ethernet/sis/sis900.c
> b/drivers/net/ethernet/sis/sis900.c index fb9f6b3..edf5edb 100644
> --- a/drivers/net/ethernet/sis/sis900.c
> +++ b/drivers/net/ethernet/sis/sis900.c
> @@ -2479,7 +2479,7 @@ static int sis900_resume(struct pci_dev *pci_dev)
>  	netif_start_queue(net_dev);
> 
>  	/* Workaround for EDB */
> -	sis900_set_mode(ioaddr, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
> +	sis900_set_mode(sis_priv, HW_SPEED_10_MBPS, FDX_CAPABLE_HALF_SELECTED);
> 
>  	/* Enable all known interrupts by setting the interrupt mask. */
>  	sw32(imr, RxSOVR | RxORN | RxERR | RxOK | TxURN | TxERR | TxIDLE);
This seems to fix it. I was able to repeatedly suspend and resume.

On my first resume try I did get a netdev watchdog timeout right after I got 
back to my shell prompt, but it wasn't reproducable. So, I'm assuming it's 
some unrelated rc or hardware issue. Thought I might better mention it.

Jan
