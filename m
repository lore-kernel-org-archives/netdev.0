From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next] ethtool: consolidate work with ethtool_ops
Date: Mon, 7 Jan 2013 16:19:02 +0000
Message-ID: <1357575542.2658.1.camel@bwh-desktop.uk.solarflarecom.com>
References: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<richardcochran@gmail.com>, <greearb@candelatech.com>,
	<jeffrey.t.kirsher@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:8584 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753598Ab3AGQTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jan 2013 11:19:08 -0500
In-Reply-To: <1357561574-14255-1-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-01-07 at 13:26 +0100, Jiri Pirko wrote:
> No need to check if ethtool_ops == NULL since it can't be.
> Use local variable "ops" in functions where it is present
> instead of dev->ethtool_ops
> Introduce local variable "ops" in functions where dev->ethtool_ops is used
> many times.
> 
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  net/core/ethtool.c | 45 +++++++++++++++++++++------------------------
>  1 file changed, 21 insertions(+), 24 deletions(-)
> 
> diff --git a/net/core/ethtool.c b/net/core/ethtool.c
> index a870543..08c213e 100644
> --- a/net/core/ethtool.c
> +++ b/net/core/ethtool.c
[...]
> @@ -1082,9 +1083,10 @@ static int ethtool_phys_id(struct net_device *dev, void __user *useraddr)
>  {
>  	struct ethtool_value id;
>  	static bool busy;
> +	const struct ethtool_ops *ops = dev->ethtool_ops;
>  	int rc;
>  
> -	if (!dev->ethtool_ops->set_phys_id)
> +	if (ops->set_phys_id)
>  		return -EOPNOTSUPP;
[...]

This condition is inverted.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
