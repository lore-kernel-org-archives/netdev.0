From: John Fastabend <john.r.fastabend@intel.com>
Subject: Re: [PATCH net-next V5 7/8] net/dcb: Add an optional max rate attribute
Date: Tue, 03 Apr 2012 07:39:22 -0700
Message-ID: <4F7B0B9A.2050603@intel.com>
References: <1333451407-5293-1-git-send-email-amirv@mellanox.com> <1333451407-5293-8-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Roland Dreier <roland@purestorage.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Oren Duer <oren@mellanox.com>,
	Amir Vadai <amirv@dev.mellanox.co.il>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:31094 "EHLO mga09.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752894Ab2DCOjX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Apr 2012 10:39:23 -0400
In-Reply-To: <1333451407-5293-8-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 4/3/2012 4:10 AM, Amir Vadai wrote:
> Although not specified in 8021Qaz spec, it could be useful to enable drivers
> whose HW supports setting a rate limit for an ETS TC. This patch adds this
> optional attribute to DCB netlink. To use it, drivers should implement and
> register the callbacks ieee_setmaxrate and ieee_getmaxrate. The units are 64
> bits long and specified in Kbps to enable usage over both slow and very fast
> networks.
> 
> Signed-off-by: Amir Vadai <amirv@mellanox.com>
> ---

[...]

>  
>  static const struct nla_policy dcbnl_ieee_app[DCB_ATTR_IEEE_APP_MAX + 1] = {
> @@ -1243,6 +1245,14 @@ static int dcbnl_ieee_fill(struct sk_buff *skb, struct net_device *netdev)
>  			NLA_PUT(skb, DCB_ATTR_IEEE_ETS, sizeof(ets), &ets);
>  	}
>  
> +	if (ops->ieee_getmaxrate) {
> +		struct ieee_maxrate maxrate;
> +		err = ops->ieee_getmaxrate(netdev, &maxrate);
> +		if (!err)
> +			NLA_PUT(skb, DCB_ATTR_IEEE_MAXRATE, sizeof(maxrate),
> +					&maxrate);

Don't use the NLA_PUT macros anymore they are error prone use nla_put(). Dave
has a series to remove these no point in adding more.

Thanks,
John
