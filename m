From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] ipv6: remove another useless NULL check
Date: Mon, 29 Oct 2012 09:33:08 +0100
Message-ID: <1351499588.7394.198.camel@edumazet-glaptop>
References: <1351491005.7394.7.camel@edumazet-glaptop>
	 <1351498585-20087-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f174.google.com ([209.85.215.174]:59968 "EHLO
	mail-ea0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756665Ab2J2IdN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2012 04:33:13 -0400
Received: by mail-ea0-f174.google.com with SMTP id c13so1591384eaa.19
        for <netdev@vger.kernel.org>; Mon, 29 Oct 2012 01:33:11 -0700 (PDT)
In-Reply-To: <1351498585-20087-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-10-29 at 16:16 +0800, Cong Wang wrote:
> When 'rt' is NULL, '&rt->dst' is NULL too because >dst
> is always the first field of 'rt'. And dst_release accepts
> NULL.
> 
> Cc: Eric Dumazet <eric.dumazet@gmail.com>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> ---
> diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
> index 8f0b12a..adeb479 100644
> --- a/net/ipv6/addrconf.c
> +++ b/net/ipv6/addrconf.c
> @@ -2027,8 +2027,7 @@ void addrconf_prefix_rcv(struct net_device *dev, u8 *opt, int len, bool sllao)
>  			addrconf_prefix_route(&pinfo->prefix, pinfo->prefix_len,
>  					      dev, expires, flags);
>  		}
> -		if (rt)
> -			dst_release(&rt->dst);
> +		dst_release(&rt->dst);
>  	}
>  
>  	/* Try to figure out our local address for this prefix */



Could you instead introduce a helper for that, like we have in IPv4.

(ip_rt_put() -> ip6_rt_put() or something...)

See my followup patch for ipv4
