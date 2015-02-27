From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next] ipv6: convert printk call to pr_err macro
Date: Thu, 26 Feb 2015 18:39:09 -0800
Message-ID: <1425004749.2690.3.camel@perches.com>
References: <1424999650-25847-1-git-send-email-ipm@chirality.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Ian Morris <ipm@chirality.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay0061.hostedemail.com ([216.40.44.61]:41109 "EHLO
	smtprelay.hostedemail.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751287AbbB0CjM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Feb 2015 21:39:12 -0500
In-Reply-To: <1424999650-25847-1-git-send-email-ipm@chirality.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 01:14 +0000, Ian Morris wrote:
> change a printk(KERN_ERR to a pr_err macro. No changes detected by
> objdiff.
[]
> diff --git a/net/ipv6/exthdrs_core.c b/net/ipv6/exthdrs_core.c
[]
> @@ -198,7 +198,7 @@ int ipv6_find_hdr(const struct sk_buff *skb, unsigned int *offset,
>  
>  		ip6 = skb_header_pointer(skb, *offset, sizeof(_ip6), &_ip6);
>  		if (!ip6 || (ip6->version != 6)) {
> -			printk(KERN_ERR "IPv6 header not found\n");
> +			pr_err("IPv6 header not found\n");

Hello Ian.

I presume this message is very rare, (is it even possible?)
but I also think it'd be better to use

			netdev_err(skb->dev, "IPv6 header not found\n");

so that the network device can be easily identified.
