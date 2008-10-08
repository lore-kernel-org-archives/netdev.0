From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] 8139too: move wmb before TX DMA start
Date: Wed, 8 Oct 2008 11:16:00 +0100
Message-ID: <20081008101558.GH7331@solarflare.com>
References: <48EC64E1.5070806@linuxtv.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Andreas Oberritter <obi@linuxtv.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:53658 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752974AbYJHKQH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 06:16:07 -0400
Content-Disposition: inline
In-Reply-To: <48EC64E1.5070806@linuxtv.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andreas Oberritter wrote:
> From: Andreas Oberritter <obi@linuxtv.org>
> 
> The write barrier should be used before starting a DMA transfer. This fixes
> a problem, where almost all packets received on another machine had garbled
> content. Tested with an RTL8100C on a MIPS machine.
> 
> Signed-off-by: Andreas Oberritter <obi@linuxtv.org>
> 
> diff --git a/drivers/net/8139too.c b/drivers/net/8139too.c
> index 53bd903..44344af 100644
> --- a/drivers/net/8139too.c
> +++ b/drivers/net/8139too.c
> @@ -1716,13 +1716,13 @@ static int rtl8139_start_xmit (struct sk_buff *skb, struct net_device *dev)
>  	}
>  
>  	spin_lock_irqsave(&tp->lock, flags);
> +	wmb();
[...]

All memory barriers need a comment to explain why and what they're doing.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
