From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] Ethtool: Free memory leak in do_sprivflags()
Date: Mon, 1 Jul 2013 16:59:13 +0100
Message-ID: <1372694353.2083.2.camel@bwh-desktop.uk.level5networks.com>
References: <1371038398-15934-1-git-send-email-yuvalmin@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Yuval Mintz <yuvalmin@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:39125 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754537Ab3GAP7R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Jul 2013 11:59:17 -0400
In-Reply-To: <1371038398-15934-1-git-send-email-yuvalmin@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-06-12 at 14:59 +0300, Yuval Mintz wrote:
> cmdline is allocated for usage in parse_generic_cmdline(), but is not
> released after its final usage.
> 
> Signed-off-by: Yuval Mintz <yuvalmin@broadcom.com>

Applied.

Ben.

> ---
>  ethtool.c | 1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/ethtool.c b/ethtool.c
> index 8cc10b5..b80494d 100644
> --- a/ethtool.c
> +++ b/ethtool.c
> @@ -3521,6 +3521,7 @@ static int do_sprivflags(struct cmd_context *ctx)
>  		cmdline[i].seen_val = &seen_flags;
>  	}
>  	parse_generic_cmdline(ctx, &any_changed, cmdline, strings->len);
> +	free(cmdline);
>  
>  	flags.cmd = ETHTOOL_GPFLAGS;
>  	if (send_ioctl(ctx, &flags)) {

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
