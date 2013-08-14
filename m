From: David Miller <davem@davemloft.net>
Subject: Re: [Patch net-next] net: sync some IP headers with glibc
Date: Wed, 14 Aug 2013 13:42:46 -0700 (PDT)
Message-ID: <20130814.134246.1152657041177088716.davem@davemloft.net>
References: <1376383054-9184-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tmb@mageia.org, libc-alpha@sourceware.org,
	yoshfuji@linux-ipv6.org, carlos@redhat.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59756 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932912Ab3HNUms (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Aug 2013 16:42:48 -0400
In-Reply-To: <1376383054-9184-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Tue, 13 Aug 2013 16:37:33 +0800

> @@ -23,31 +23,54 @@
>  
>  /* Standard well-defined IP protocols.  */
>  enum {
> -  IPPROTO_IP = 0,		/* Dummy protocol for TCP		*/
> -  IPPROTO_ICMP = 1,		/* Internet Control Message Protocol	*/

> +  IPPROTO_IP = 0,		/* Dummy protocol for TCP. */

Please don't do unrelated things like reformat comments, it makes the
path much harder to audit.

> -
> +#if __UAPI_DEF_IN6_ADDR
>  struct in6_addr {
>  	union {
>  		__u8		u6_addr8[16];
> +#if __UAPI_DEF_IN6_ADDR
>  		__be16		u6_addr16[8];

The same CPP test twice inside of itself, the second test seems
superfluous.  I bet this second one was supposed to be
__UAPI_DEF_IN6_ADDR_ALT instead of __UAPI_DEF_IN6_ADDR.

> -#define IPPROTO_HOPOPTS		0	/* IPv6 hop-by-hop options	*/
> -#define IPPROTO_ROUTING		43	/* IPv6 routing header		*/
> -#define IPPROTO_FRAGMENT	44	/* IPv6 fragmentation header	*/
> -#define IPPROTO_ICMPV6		58	/* ICMPv6			*/
> -#define IPPROTO_NONE		59	/* IPv6 no next header		*/
> -#define IPPROTO_DSTOPTS		60	/* IPv6 destination options	*/
> -#define IPPROTO_MH		135	/* IPv6 mobility header		*/
> +#if __UAPI_DEF_IPPROTO_V6
> +enum {
> +  IPPROTO_HOPOPTS = 0,		/* IPv6 hop-by-hop options      */

Again, do not reformat things, it's an unrelated change and makes
this patch harder to review.
