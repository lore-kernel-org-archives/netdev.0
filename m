From: walter harms <wharms@bfs.de>
Subject: Re: [patch v2] bridge: make buffer larger in br_setlink()
Date: Fri, 07 Dec 2012 17:07:24 +0100
Message-ID: <50C2143C.2010200@bfs.de>
References: <20121207111045.GA9676@elgon.mountain>
Reply-To: wharms@bfs.de
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	"David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, Thomas Graf <tgraf@suug.ch>
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx01.sz.bfs.de ([194.94.69.103]:22382 "EHLO mx01.sz.bfs.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1030757Ab2LGQH2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 7 Dec 2012 11:07:28 -0500
In-Reply-To: <20121207111045.GA9676@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Am 07.12.2012 12:10, schrieb Dan Carpenter:
> We pass IFLA_BRPORT_MAX to nla_parse_nested() so we need
> IFLA_BRPORT_MAX + 1 elements.  Also Smatch complains that we read past
> the end of the array when in br_set_port_flag() when it's called with
> IFLA_BRPORT_FAST_LEAVE.
> 



I have no clue why nla_parse_nested() need IFLA_BRPORT_MAX elements.
but the majory of loop look like
for(i=0;i<max;++)
most programmers will think this way.
So it seems the place to fix is nla_parse_nested().
doing not so is asking for trouble (in the long run).
At least this function needs a big warning label that (max-1)
is actually needed.


just my two cents,
 wh


> Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
> ---
> v2: Style tweak.
> 
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
> +	struct nlattr *tb[IFLA_BRPORT_MAX + 1];
>  	int err;
>  
>  	ifm = nlmsg_data(nlh);
> 
> --
> To unsubscribe from this list: send the line "unsubscribe kernel-janitors" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
> 
