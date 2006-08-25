From: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>
Subject: RE: [IPV6] Q: corrupt checksums when transferring data
Date: Fri, 25 Aug 2006 16:23:41 -0700
Message-ID: <36D9DB17C6DE9E40B059440DB8D95F5281CFB6@orsmsx418.amr.corp.intel.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:48186 "EHLO
	orsmga101-1.jf.intel.com") by vger.kernel.org with ESMTP
	id S1422920AbWHYXXm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Aug 2006 19:23:42 -0400
Content-class: urn:content-classes:message
To: "Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> I think this the problem. Does it fix e1000? I am testing now.
> 
> TCP over IPV6 would incorrectly inherit the GSO settings on accepted
> children.
> 
> --- linux-2.6.orig/net/ipv6/tcp_ipv6.c	2006-08-03
09:09:16.000000000
> -0700 +++ linux-2.6/net/ipv6/tcp_ipv6.c	2006-08-25
15:30:31.000000000
> -0700 @@ -944,7 +944,7 @@
>  	 * comment in that function for the gory details. -acme
>  	 */
> 
> -	sk->sk_gso_type = SKB_GSO_TCPV6;
> +	newsk->sk_gso_type = SKB_GSO_TCPV6;
>  	__ip6_dst_store(newsk, dst, NULL);
> 
>  	newtcp6sk = (struct tcp6_sock *)newsk;

ah, no more errors, I didn't go through and validate much more past
that. I'm now able to do hardware offloads with no errors.

I think it's a good patch, at least it makes sense to me and works for
me.

Thanks!
 Jesse
