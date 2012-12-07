From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [patch] bridge: make buffer larger in br_setlink()
Date: Fri, 7 Dec 2012 09:31:07 +0000
Message-ID: <20121207093107.GA2996@casper.infradead.org>
References: <20121207061854.GB18220@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:46224 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753921Ab2LGJbO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Dec 2012 04:31:14 -0500
Content-Disposition: inline
In-Reply-To: <20121207061854.GB18220@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/07/12 at 09:18am, Dan Carpenter wrote:
> __IFLA_BRPORT_MAX is one larger than IFLA_BRPORT_MAX.  We pass
> IFLA_BRPORT_MAX to nla_parse_nested() so we need IFLA_BRPORT_MAX + 1
> elements.  Also Smatch complains that we read past the end of the array
> when in br_set_port_flag() when it's called with IFLA_BRPORT_FAST_LEAVE.
> 
> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> Only needed in linux-next.
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index 850b7d1..cfc5cfe 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -239,7 +239,7 @@ int br_setlink(struct net_device *dev, struct nlmsghdr *nlh)
>  	struct ifinfomsg *ifm;
>  	struct nlattr *protinfo;
>  	struct net_bridge_port *p;
> -	struct nlattr *tb[IFLA_BRPORT_MAX];
> +	struct nlattr *tb[__IFLA_BRPORT_MAX];
>  	int err;
>  
>  	ifm = nlmsg_data(nlh);

I know it's nitpicking but could you use IFLA_BRPORT_MAX+1 for
consistency?
