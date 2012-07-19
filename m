From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] sfc: initialize dynamic sysfs attributes for lockdep
Date: Thu, 19 Jul 2012 18:19:05 +0100
Message-ID: <1342718345.2617.46.camel@bwh-desktop.uk.solarflarecom.com>
References: <1342717485-24034-1-git-send-email-mschmidt@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>,
	Solarflare linux maintainers <linux-net-drivers@solarflare.com>
To: Michal Schmidt <mschmidt@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:64413 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751337Ab2GSRTJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jul 2012 13:19:09 -0400
In-Reply-To: <1342717485-24034-1-git-send-email-mschmidt@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-07-19 at 19:04 +0200, Michal Schmidt wrote:
> Dynamically allocated sysfs attributes must be initialized using
> sysfs_attr_init(), otherwise lockdep complains:
> BUG: key <address> not in .data!
>
> Signed-off-by: Michal Schmidt <mschmidt@redhat.com>

Acked-by: Ben Hutchings <bhutchings@solarflare.com>

> ---
>  drivers/net/ethernet/sfc/mcdi_mon.c |    1 +
>  1 file changed, 1 insertion(+)
> 
> diff --git a/drivers/net/ethernet/sfc/mcdi_mon.c b/drivers/net/ethernet/sfc/mcdi_mon.c
> index fb7f65b..1d552f0 100644
> --- a/drivers/net/ethernet/sfc/mcdi_mon.c
> +++ b/drivers/net/ethernet/sfc/mcdi_mon.c
> @@ -222,6 +222,7 @@ efx_mcdi_mon_add_attr(struct efx_nic *efx, const char *name,
>  	attr->index = index;
>  	attr->type = type;
>  	attr->limit_value = limit_value;
> +	sysfs_attr_init(&attr->dev_attr.attr);
>  	attr->dev_attr.attr.name = attr->name;
>  	attr->dev_attr.attr.mode = S_IRUGO;
>  	attr->dev_attr.show = reader;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
