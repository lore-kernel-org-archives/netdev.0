From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: NIU driver: Sun x8 Express Quad Gigabit Ethernet Adapter
Date: Wed, 12 Nov 2008 12:54:53 +0000
Message-ID: <1226494493.3016.3.camel@achroite>
References: <20081112.014923.68124784.davem@davemloft.net>
	 <1226487710.6834.53.camel@localhost.localdomain>
	 <20081112.035240.226243372.davem@davemloft.net>
	 <20081112.041143.11487260.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: jdb@comx.dk, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smarthost01.mail.zen.net.uk ([212.23.3.140]:40047 "EHLO
	smarthost01.mail.zen.net.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752197AbYKLMy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Nov 2008 07:54:57 -0500
In-Reply-To: <20081112.041143.11487260.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2008-11-12 at 04:11 -0800, David Miller wrote:
[...]
> So the following patch should fix this bug.  writeq() should
> be OK as-is, so doesn't need a similar change.
> 
> diff --git a/drivers/net/niu.c b/drivers/net/niu.c
> index 9acb5d7..d8463b1 100644
> --- a/drivers/net/niu.c
> +++ b/drivers/net/niu.c
> @@ -51,8 +51,7 @@ MODULE_VERSION(DRV_MODULE_VERSION);
>  #ifndef readq
>  static u64 readq(void __iomem *reg)
>  {
> -	return (((u64)readl(reg + 0x4UL) << 32) |
> -		(u64)readl(reg));
> +	return ((u64) readl(reg)) | (((u64) readl(reg + 4UL)) << 32);
>  }

Since there's no sequence point between the reads, there's no guarantee
that the reads happen in the order written (regardless of barriers
inside readl()).  This needs to be split into two statements.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

