From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch net-next v3 16/17] bridge: add brport flags to dflt
 bridge_getlink
Date: Tue, 25 Nov 2014 22:07:53 +0000
Message-ID: <20141125220753.GD3912@casper.infradead.org>
References: <1416911328-10979-1-git-send-email-jiri@resnulli.us>
 <1416911328-10979-17-git-send-email-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net, nhorman@tuxdriver.com,
	andy@greyhouse.net, dborkman@redhat.com, ogerlitz@mellanox.com,
	jesse@nicira.com, pshelar@nicira.com, azhou@nicira.com,
	ben@decadent.org.uk, stephen@networkplumber.org,
	jeffrey.t.kirsher@intel.com, vyasevic@redhat.com,
	xiyou.wangcong@gmail.com, john.r.fastabend@intel.com,
	edumazet@google.com, jhs@mojatatu.com, sfeldma@gmail.com,
	f.fainelli@gmail.com, roopa@cumulusnetworks.com,
	linville@tuxdriver.com, jasowang@redhat.com, ebiederm@xmission.com,
	nicolas.dichtel@6wind.com, ryazanov.s.a@gmail.com,
	buytenh@wantstofly.org, aviadr@mellanox.com, nbd@openwrt.org,
	alexei.starovoitov@gmail.com, Neil.Jerram@metaswitch.com,
	ronye@mellanox.com, simon.horman@netronome.com,
	alexander.h.duyck@redhat.com, john.ronciak@intel.com,
	mleitner@redhat.com, shrijeet@gmail.com, gospo@cumulusnetworks.com,
	bcrl@kvack.org
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:56674 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751563AbaKYWH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Nov 2014 17:07:57 -0500
Content-Disposition: inline
In-Reply-To: <1416911328-10979-17-git-send-email-jiri@resnulli.us>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/25/14 at 11:28am, Jiri Pirko wrote:
> From: Scott Feldman <sfeldma@gmail.com>
> 
> To allow brport device to return current brport flags set on port.  Add
> returned flags to nested IFLA_PROTINFO netlink msg built in dflt getlink.
> With this change, netlink msg returned for bridge_getlink contains the port's
> offloaded flag settings (the port's SELF settings).
> 
> Signed-off-by: Scott Feldman <sfeldma@gmail.com>
> Signed-off-by: Jiri Pirko <jiri@resnulli.us>

Minor nit below. Otherwise:

Acked-by: Thomas Graf <tgraf@suug.ch>

> diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
> index bd5e783..91e5368 100644
> --- a/net/core/rtnetlink.c
> +++ b/net/core/rtnetlink.c
> @@ -2687,12 +2687,22 @@ static int rtnl_fdb_dump(struct sk_buff *skb, struct netlink_callback *cb)
>  	return skb->len;
>  }
>  
> +static int brport_nla_put_flag(struct sk_buff *skb, u32 flags, u32 mask,
> +			       unsigned int attrnum, unsigned int flag)
> +{
> +	if (mask & flag)
> +		return nla_put_u8(skb, attrnum, !!(flags & flag));

nla_put_flag()?
