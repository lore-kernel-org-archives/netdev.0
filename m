From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH] gianfar: Fix a filer bug
Date: Thu, 10 Dec 2009 18:07:12 +0300
Message-ID: <20091210150712.GA17851@oksana.dev.rtsoft.ru>
References: <1260366911-15178-1-git-send-email-Sandeep.Kumar@freescale.com>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from imap.ru.mvista.com ([213.79.90.228]:53951 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1753502AbZLJPHG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 10:07:06 -0500
Content-Disposition: inline
In-Reply-To: <1260366911-15178-1-git-send-email-Sandeep.Kumar@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 09, 2009 at 07:25:11PM +0530, Sandeep Gopalpet wrote:
> We need to enable filer whenever we need to use multiple RX
> queues. Also, need to program RIR0 register with the required
> distribution we require, if using RX filer hashing support for
> packet distribution to multiple queues.
> 
> Signed-off-by: Sandeep Gopalpet <Sandeep.Kumar@freescale.com>
> ---
[...]
> -	if (priv->rx_filer_enable)
> +	if (priv->rx_filer_enable) {
>  		rctrl |= RCTRL_FILREN;
> +		/* Program the RIR0 reg with the required distribution */
> +		regs->rir0 = DEFAULT_RIR0;

You cannot access regs directly. You have to use gfar_write
since regs is ioremapped memory.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
