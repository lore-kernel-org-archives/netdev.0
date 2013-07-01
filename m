From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] Ethtool: Beautify private flags print
Date: Mon, 1 Jul 2013 16:58:52 +0100
Message-ID: <1372694332.2083.1.camel@bwh-desktop.uk.level5networks.com>
References: <1369544155-12279-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <joe@perches.com>, <eilong@broadcom.com>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39112 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753357Ab3GAP64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 11:58:56 -0400
In-Reply-To: <1369544155-12279-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-05-26 at 07:55 +0300, Yuval Mintz wrote:
> When printing the private flags of the device, align all strings
> to have the same length.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>
> ---
> Changes from V1:
>   - use "%-*s" instead of printing white spaces in for-loop.

Applied; sorry for the delay.

Ben.

> ---
>  ethtool.c | 12 +++++++++++-
>  1 file changed, 11 insertions(+), 1 deletion(-)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 8cc10b5..57a6e01 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3445,6 +3445,7 @@ static int do_gprivflags(struct cmd_context *ctx)
>  	struct ethtool_gstrings *strings;
>  	struct ethtool_value flags;
>  	unsigned int i;
> +	int max_len = 0, cur_len;
>  
>  	if (ctx->argc != 0)
>  		exit_bad_args();
> @@ -3472,9 +3473,18 @@ static int do_gprivflags(struct cmd_context *ctx)
>  		return 1;
>  	}
>  
> +	/* Find longest string and align all strings accordingly */
> +	for (i = 0; i < strings->len; i++) {
> +		cur_len = strlen((const char*)strings->data +
> +					      i * ETH_GSTRING_LEN);
> +		if (cur_len > max_len)
> +			max_len = cur_len;
> +	}
> +
>  	printf("Private flags for %s:\n", ctx->devname);
>  	for (i = 0; i < strings->len; i++)
> -		printf("%s: %s\n",
> +		printf("%-*s: %s\n",
> +		       max_len,
>  		       (const char *)strings->data + i * ETH_GSTRING_LEN,
>  		       (flags.data & (1U << i)) ? "on" : "off");
>  

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
