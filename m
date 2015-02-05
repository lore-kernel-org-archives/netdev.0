From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] dsa: correctly determine the number of switches in a
 system
Date: Thu, 05 Feb 2015 11:41:43 -0800
Message-ID: <54D3C777.4040901@gmail.com>
References: <20150205135409.GB29383@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Tobias Waldekranz <tobias@waldekranz.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:49384 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751000AbbBETlx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Feb 2015 14:41:53 -0500
Received: by mail-pa0-f46.google.com with SMTP id lj1so11954381pab.5
        for <netdev@vger.kernel.org>; Thu, 05 Feb 2015 11:41:52 -0800 (PST)
In-Reply-To: <20150205135409.GB29383@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/15 05:54, Tobias Waldekranz wrote:
> The number of connected switches was sourced from the number of
> children to the DSA node, change it to the number of available
> children, skipping any disabled switches.
> 
> Signed-off-by: Tobias Waldekranz <tobias@waldekranz.com>

Acked-by: Florian Fainelli <f.fainelli@gmail.com>
Fixes: 5e95329b701c4 ("dsa: add device tree bindings to register DSA
switches")

> ---
>  net/dsa/dsa.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
> 
> diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
> index 3731714..2173402 100644
> --- a/net/dsa/dsa.c
> +++ b/net/dsa/dsa.c
> @@ -603,7 +603,7 @@ static int dsa_of_probe(struct platform_device *pdev)
>  
>  	pdev->dev.platform_data = pd;
>  	pd->netdev = &ethernet_dev->dev;
> -	pd->nr_chips = of_get_child_count(np);
> +	pd->nr_chips = of_get_available_child_count(np);
>  	if (pd->nr_chips > DSA_MAX_SWITCHES)
>  		pd->nr_chips = DSA_MAX_SWITCHES;
>  
> 


-- 
Florian
