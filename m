From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net-next] net: move inet_dport/inet_num in sock_common
Date: Tue, 27 Nov 2012 19:05:56 +0000
Message-ID: <1354043156.2701.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1354028815.14302.35.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Ling Ma <ling.ma.program@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:19188 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753234Ab2K0TF7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Nov 2012 14:05:59 -0500
In-Reply-To: <1354028815.14302.35.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-11-27 at 07:06 -0800, Eric Dumazet wrote:
[...]
> --- a/include/net/inet_timewait_sock.h
> +++ b/include/net/inet_timewait_sock.h
> @@ -112,6 +112,9 @@ struct inet_timewait_sock {
>  #define tw_net			__tw_common.skc_net
>  #define tw_daddr        	__tw_common.skc_daddr
>  #define tw_rcv_saddr    	__tw_common.skc_rcv_saddr
> +#define tw_dport		__tw_common.skc_dport
> +#define tw_num			__tw_common.skc_num
> +
>  	int			tw_timeout;
>  	volatile unsigned char	tw_substate;
>  	unsigned char		tw_rcv_wscale;
> @@ -119,8 +122,6 @@ struct inet_timewait_sock {
>  	/* Socket demultiplex comparisons on incoming packets. */
>  	/* these three are in inet_sock */
>  	__be16			tw_sport;
> -	__be16			tw_dport;
> -	__u16			tw_num;
>  	kmemcheck_bitfield_begin(flags);
>  	/* And these are ours. */
>  	unsigned int		tw_ipv6only     : 1,
> diff --git a/include/net/sock.h b/include/net/sock.h
> index c945fba..e4bab2e 100644
> --- a/include/net/sock.h
> +++ b/include/net/sock.h
> @@ -132,6 +132,8 @@ struct net;
>   *	@skc_rcv_saddr: Bound local IPv4 addr
>   *	@skc_hash: hash value used with various protocol lookup tables
>   *	@skc_u16hashes: two u16 hash values used by UDP lookup tables
> + *	@skc_dport: placeholder for inet_dport/tw_dport
> + *	@skc_num: placeholder for inet_num/tw_num
>   *	@skc_family: network address family
>   *	@skc_state: Connection state
>   *	@skc_reuse: %SO_REUSEADDR setting
> @@ -149,8 +151,8 @@ struct net;
>   *	for struct sock and struct inet_timewait_sock.
>   */
>  struct sock_common {
> -	/* skc_daddr and skc_rcv_saddr must be grouped :
> -	 * cf INET_MATCH() and INET_TW_MATCH()
> +	/* skc_daddr and skc_rcv_saddr must be grouped on a 8 bytes aligned
> +	 * address on 64bit arches : cf INET_MATCH() and INET_TW_MATCH()

__aligned(8)?

>  	 */
>  	__be32			skc_daddr;
>  	__be32			skc_rcv_saddr;
> @@ -159,6 +161,10 @@ struct sock_common {
>  		unsigned int	skc_hash;
>  		__u16		skc_u16hashes[2];
>  	};
> +	/* skc_dport && skc_num must be grouped as well */
> +	__be16			skc_dport;

__aligned(4)?

> +	__u16			skc_num;
> +
>  	unsigned short		skc_family;
>  	volatile unsigned char	skc_state;
>  	unsigned char		skc_reuse;

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
