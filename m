From: Ben Greear <greearb@candelatech.com>
Subject: Re: [patch net-next 04/15] rtnetlink: remove usage of dev->master
Date: Sun, 30 Dec 2012 10:00:55 -0800
Message-ID: <50E08157.2010001@candelatech.com>
References: <1356868702-8144-1-git-send-email-jiri@resnulli.us> <1356868702-8144-5-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net, edumazet@google.com,
	bhutchings@solarflare.com, faisal.latif@intel.com,
	shemminger@vyatta.com, fbl@redhat.com, roland@kernel.org,
	sean.hefty@intel.com, hal.rosenstock@gmail.com, fubar@us.ibm.com,
	andy@greyhouse.net, divy@chelsio.com, jitendra.kalsaria@qlogic.com,
	sony.chacko@qlogic.com, linux-driver@qlogic.com, kaber@trash.net,
	ursula.braun@de.ibm.com, blaschka@linux.vnet.ibm.com,
	schwidefsky@de.ibm.com, heiko.carstens@de.ibm.com,
	ebiederm@xmission.com, joe@perches.com, amwang@redhat.com,
	nhorman@tuxdriver.com, john.r.fastabend@intel.com,
	pablo@netfilter.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:34222 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754696Ab2L3SC3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Dec 2012 13:02:29 -0500
In-Reply-To: <1356868702-8144-5-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/30/2012 03:58 AM, Jiri Pirko wrote:
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>
> ---
>   net/core/rtnetlink.c | 69 ++++++++++++++++++++++++++++------------------------
>   1 file changed, 37 insertions(+), 32 deletions(-)
>
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index 2ef7a56..ae612f4 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -880,6 +880,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   	const struct rtnl_link_stats64 *stats;
>   	struct nlattr *attr, *af_spec;
>   	struct rtnl_af_ops *af_ops;
> +	struct net_device *upper_dev = netdev_master_upper_dev_get(dev);
>
>   	ASSERT_RTNL();
>   	nlh = nlmsg_put(skb, pid, seq, type, sizeof(*ifm), flags);
> @@ -908,8 +909,8 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
>   #endif
>   	    (dev->ifindex != dev->iflink &&
>   	     nla_put_u32(skb, IFLA_LINK, dev->iflink)) ||
> -	    (dev->master &&
> -	     nla_put_u32(skb, IFLA_MASTER, dev->master->ifindex)) ||
> +	    (upper_dev &&
> +	     nla_put_u32(skb, IFLA_MASTER, upper_dev->ifindex)) ||

This seems confusing to me.  You are calling the new variable 'upper_dev',
but it seems you are actually using it as a lower_dev???

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
