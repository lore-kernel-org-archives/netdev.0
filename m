From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: [PATCH 2/2] ipv6: header documentation
Date: Sun, 03 Aug 2014 15:48:40 -0700
Message-ID: <53DEBC48.5030309@infradead.org>
References: <1406928683-4317-1-git-send-email-karoly.kemeny@gmail.com> <1406928683-4317-2-git-send-email-karoly.kemeny@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Karoly Kemeny <karoly.kemeny@gmail.com>, netdev@vger.kernel.org,
	davem@davemloft.net, linux-doc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from casper.infradead.org ([85.118.1.10]:59764 "EHLO
	casper.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751835AbaHCWsr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Aug 2014 18:48:47 -0400
In-Reply-To: <1406928683-4317-2-git-send-email-karoly.kemeny@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/01/14 14:31, Karoly Kemeny wrote:
> Signed-off-by: Karoly Kemeny <karoly.kemeny@gmail.com>
> ---
>  include/net/ipv6.h | 40 ++++++++++++++++++++++++++++------------
>  1 file changed, 28 insertions(+), 12 deletions(-)
> 
> diff --git a/include/net/ipv6.h b/include/net/ipv6.h
> index a2db816..7798a97 100644
> --- a/include/net/ipv6.h
> +++ b/include/net/ipv6.h
> @@ -100,8 +100,20 @@
>  #define IPV6_ADDR_MC_FLAG_RENDEZVOUS(a)	\
>  	((a)->s6_addr[1] & 0x40)
>  
> -/*
> - *	fragmentation header
> +/**
> + *	struct frag_hdr - fragmentation header
> + *	@nexthdr	- type of the next header
> + *	@reserved	- reserved field, init to zeroes on transmission,
> + *			  ignore on reception
> + *	@frag_off	- 13 MSB bit: offset relative to the start of the
> + *				      fragmented part of the packet.
> + *			- 14-15 bit : reserved, as @reserved
> + *			- LSB	    : indicates if it is the last fragment
> + *					of the file. 0 = last fragment
> + *	@identification - id of the fragmented packet,
> + *			  must be the same for all fragments of the same packet
> + *
> + *	for more info see RFC-2460

The fields (members) within a struct are listed with ':' separating them from
their descriptions (not '-').

Ditto for below.

>   */
>  
>  struct frag_hdr {
> @@ -200,23 +212,27 @@ struct ip6_ra_chain {
>  extern struct ip6_ra_chain	*ip6_ra_chain;
>  extern rwlock_t ip6_ra_lock;
>  
> -/*
> -   This structure is prepared by protocol, when parsing
> -   ancillary data and passed to IPv6.
> +/**
> + * struct ipv6_txoption - This structure is prepared by protocol, when parsing
> + * 			  ancillary data and passed to IPv6.
> + * @tot_len		- length of this structure
> + * @opt_flen		- length of extension header after fragment header
> + * @opt_nlen		- length of extension header before fragment header
> + * @hopopt		- pointer to the hop-by-hop header
> + * @dst0opt		- pointer to the first destination header
> + * @srcrt		- pointer to the routing header
> + * @dst1opt		- pointer to the second destination header
> + *
>   */
>  
>  struct ipv6_txoptions {
> -	/* Length of this structure */
>  	int			tot_len;
> -
> -	/* length of extension headers   */
> -
> -	__u16			opt_flen;	/* after fragment hdr */
> -	__u16			opt_nflen;	/* before fragment hdr */
> +	__u16			opt_flen;
> +	__u16			opt_nflen;
>  
>  	struct ipv6_opt_hdr	*hopopt;
>  	struct ipv6_opt_hdr	*dst0opt;
> -	struct ipv6_rt_hdr	*srcrt;	/* Routing Header */
> +	struct ipv6_rt_hdr	*srcrt;
>  	struct ipv6_opt_hdr	*dst1opt;
>  
>  	/* Option buffer, as read by IPV6_PKTOPTIONS, starts here. */
> 


-- 
~Randy
