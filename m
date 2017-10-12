From: David Ahern <dsahern@gmail.com>
Subject: Re: [PATCH net-next 1/1] bridge: return error code when deleting Vlan
Date: Wed, 11 Oct 2017 19:59:47 -0600
Message-ID: <24cb1770-9b4f-0008-cddb-d3f909ef2239@gmail.com>
References: <1507757385-32256-1-git-send-email-mrv@mojatatu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: Roman Mashak <mrv@mojatatu.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:46520 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751532AbdJLB7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Oct 2017 21:59:50 -0400
Received: by mail-pf0-f196.google.com with SMTP id p87so2838306pfj.3
        for <netdev@vger.kernel.org>; Wed, 11 Oct 2017 18:59:50 -0700 (PDT)
In-Reply-To: <1507757385-32256-1-git-send-email-mrv@mojatatu.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/11/17 3:29 PM, Roman Mashak wrote:
> Signed-off-by: Roman Mashak <mrv@mojatatu.com>
> ---
>  net/bridge/br_netlink.c | 6 +++---
>  1 file changed, 3 insertions(+), 3 deletions(-)
> 
> diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> index f0e8268..a1e1ca8 100644
> --- a/net/bridge/br_netlink.c
> +++ b/net/bridge/br_netlink.c
> @@ -527,11 +527,11 @@ static int br_vlan_info(struct net_bridge *br, struct net_bridge_port *p,
>  
>  	case RTM_DELLINK:
>  		if (p) {
> -			nbp_vlan_delete(p, vinfo->vid);
> +			err = nbp_vlan_delete(p, vinfo->vid);
>  			if (vinfo->flags & BRIDGE_VLAN_INFO_MASTER)
> -				br_vlan_delete(p->br, vinfo->vid);
> +				err = br_vlan_delete(p->br, vinfo->vid);

err is reset here. What if nbp_vlan_delete fails and br_vlan_delete
succeeds?


>  		} else {
> -			br_vlan_delete(br, vinfo->vid);
> +			err = br_vlan_delete(br, vinfo->vid);
>  		}
>  		break;
>  	}
> 
