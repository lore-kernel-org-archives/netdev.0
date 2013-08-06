From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH net-next] net: Add low-latency/polling support for UDP
 multicast
Date: Tue, 06 Aug 2013 10:13:07 +0300
Message-ID: <5200A203.2090306@linux.intel.com>
References: <20130805212257.GB6904@sbohrermbp13-local.rgmadvisors.com> <1375741001-20553-1-git-send-email-sbohrer@rgmadvisors.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Amir Vadai <amirv@mellanox.com>, tomk@rgmadvisors.com
To: Shawn Bohrer <sbohrer@rgmadvisors.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:26979 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754453Ab3HFHNL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Aug 2013 03:13:11 -0400
In-Reply-To: <1375741001-20553-1-git-send-email-sbohrer@rgmadvisors.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/08/2013 01:16, Shawn Bohrer wrote:
> Set the napi id for each socket in the multicast path to enable
> low-latency/polling support.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
>  net/ipv4/udp.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
> index 766e6ba..0d0da17 100644
> --- a/net/ipv4/udp.c
> +++ b/net/ipv4/udp.c
> @@ -1596,6 +1596,7 @@ static int __udp4_lib_mcast_deliver(struct net *net, struct sk_buff *skb,
>  	dif = skb->dev->ifindex;
>  	sk = udp_v4_mcast_next(net, sk, uh->dest, daddr, uh->source, saddr, dif);
>  	while (sk) {
> +		sk_mark_napi_id(sk, skb);
>  		stack[count++] = sk;
>  		sk = udp_v4_mcast_next(net, sk_nulls_next(sk), uh->dest,
>  				       daddr, uh->source, saddr, dif);
> 

Looks OK.
To be complete, you want to do the same for __udp6_lib_mcast_deliver().

-Eliezer
