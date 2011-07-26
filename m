From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH net-next-2.6] bonding: reduce noise during init
Date: Tue, 26 Jul 2011 14:54:46 -0700
Message-ID: <1311717286.15386.34.camel@Joe-Laptop>
References: <1311716107-12328-1-git-send-email-andy@greyhouse.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, fubar@us.ibm.com
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:4318 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753862Ab1GZVyr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 26 Jul 2011 17:54:47 -0400
In-Reply-To: <1311716107-12328-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2011-07-26 at 17:35 -0400, Andy Gospodarek wrote:
> Many are using sysfs to configure bonding rather than module options, so
> there is no need for bonding to throw this warning in normal cases.
> Keep the message around when debugging is enabled as it might be useful
> for someone desperate enough to enable debugging, but eliminate it
> otherwise.
[]
> diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
[]
> @@ -4745,7 +4745,10 @@ static int bond_check_params(struct bond_params *params)
>  		/* miimon and arp_interval not set, we need one so things
>  		 * work as expected, see bonding.txt for details
>  		 */
> -		pr_warning("Warning: either miimon or arp_interval and arp_ip_target module parameters must be specified, otherwise bonding will not detect link failures! see bonding.txt for details.\n");
> +		pr_debug("Warning: either miimon or arp_interval and"
> +			 " arp_ip_target module parameters must be specified,"
> +			 " otherwise bonding will not detect link failures!"
> +			 "  See bonding.txt for details.\n");

I'd prefer you don't separate the format string
into multiple pieces.

