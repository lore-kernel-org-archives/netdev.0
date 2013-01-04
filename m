From: Greg Rose <gregory.v.rose@intel.com>
Subject: Re: [PATCH 3.0.y 3/3] rtnetlink: fix rtnl_calcit() and
 rtnl_dump_ifinfo()
Date: Fri, 4 Jan 2013 10:40:28 -0800
Message-ID: <20130104104028.000019ea@unknown>
References: <1357259449.2685.60.camel@bwh-desktop.uk.solarflarecom.com>
	<1357259662.2685.63.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	<stable@vger.kernel.org>, <e1000-devel@lists.sourceforge.net>,
	<netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1357259662.2685.63.camel@bwh-desktop.uk.solarflarecom.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 4 Jan 2013 00:34:22 +0000
Ben Hutchings <bhutchings@solarflare.com> wrote:

> From: Eric Dumazet <eric.dumazet@gmail.com>
> 
> commit a4b64fbe482c7766f7925f03067fc637716bfa3f upstream.
> 
> nlmsg_parse() might return an error, so test its return value before
> potential random memory accesses.
> 
> Errors introduced in commit 115c9b81928 (rtnetlink: Fix problem with
> buffer allocation)
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: Greg Rose <gregory.v.rose@intel.com>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Greg Rose <gregory.v.rose@intel.com>

> ---
>  net/core/rtnetlink.c |   18 ++++++++++--------
>  1 files changed, 10 insertions(+), 8 deletions(-)
> 
> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index e41ce2a..49f281e 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -1044,11 +1044,12 @@ static int rtnl_dump_ifinfo(struct sk_buff
> *skb, struct netlink_callback *cb) 
>  	rcu_read_lock();
>  
> -	nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> -		    ifla_policy);
> +	if (nlmsg_parse(cb->nlh, sizeof(struct rtgenmsg), tb,
> IFLA_MAX,
> +			ifla_policy) >= 0) {
>  
> -	if (tb[IFLA_EXT_MASK])
> -		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
> +		if (tb[IFLA_EXT_MASK])
> +			ext_filter_mask =
> nla_get_u32(tb[IFLA_EXT_MASK]);
> +	}
>  
>  	for (h = s_h; h < NETDEV_HASHENTRIES; h++, s_idx = 0) {
>  		idx = 0;
> @@ -1874,10 +1875,11 @@ static u16 rtnl_calcit(struct sk_buff *skb,
> struct nlmsghdr *nlh) u32 ext_filter_mask = 0;
>  	u16 min_ifinfo_dump_size = 0;
>  
> -	nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> ifla_policy); -
> -	if (tb[IFLA_EXT_MASK])
> -		ext_filter_mask = nla_get_u32(tb[IFLA_EXT_MASK]);
> +	if (nlmsg_parse(nlh, sizeof(struct rtgenmsg), tb, IFLA_MAX,
> +			ifla_policy) >= 0) {
> +		if (tb[IFLA_EXT_MASK])
> +			ext_filter_mask =
> nla_get_u32(tb[IFLA_EXT_MASK]);
> +	}
>  
>  	if (!ext_filter_mask)
>  		return NLMSG_GOODSIZE;
> 
