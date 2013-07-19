From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [patch net-next 2/3] rtnl: export physical port id via RT
 netlink
Date: Fri, 19 Jul 2013 17:07:10 +0100
Message-ID: <1374250030.2796.4.camel@bwh-desktop.uk.level5networks.com>
References: <1374242152-10325-1-git-send-email-jiri@resnulli.us>
	 <1374242152-10325-3-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <davem@davemloft.net>,
	<stephen@networkplumber.org>, <Narendra_K@Dell.com>,
	<john.r.fastabend@intel.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:35252 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751340Ab3GSQHQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Jul 2013 12:07:16 -0400
In-Reply-To: <1374242152-10325-3-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2013-07-19 at 15:55 +0200, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>  include/uapi/linux/if_link.h |  1 +
>  net/core/rtnetlink.c         | 25 ++++++++++++++++++++++++-
>  2 files changed, 25 insertions(+), 1 deletion(-)
> 
> diff --git a/include/uapi/linux/if_link.h b/include/uapi/linux/if_link.h
> index 03f6170..04c0e7a 100644
> --- a/include/uapi/linux/if_link.h
> +++ b/include/uapi/linux/if_link.h
[...]
> @@ -846,6 +847,24 @@ static int rtnl_port_fill(struct sk_buff *skb, struct net_device *dev)
>  	return 0;
>  }
>  
> +static int rtnl_phys_port_id_fill(struct sk_buff *skb, struct net_device *dev)
> +{
> +	int err;
> +	struct netdev_phys_port_id ppid;
> +
> +	if (!dev->netdev_ops->ndo_get_phys_port_id)
> +		return 0;
> +
> +	err = dev->netdev_ops->ndo_get_phys_port_id(dev, &ppid);
> +	if (err)
> +		return err;
[...]

I can imagine a driver only sometimes being able to get the physical
port ID, depending on hardware variant or firmware version.  That
shouldn't require defining another instance of net_device_ops.  So if
the error is -EOPNOTSUPP this should return 0, same as if the function
pointer is NULL.  

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
