From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: Re: gre: Support GRE over IPv6
Date: Wed, 26 Sep 2012 14:02:58 +0300
Message-ID: <20120926110258.GP13767@mwanda>
References: <20120913160105.GA29205@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: xeb@mail.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet15.oracle.com ([148.87.113.117]:17690 "EHLO
	rcsinet15.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753879Ab2IZLDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Sep 2012 07:03:16 -0400
Content-Disposition: inline
In-Reply-To: <20120913160105.GA29205@elgon.mountain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dmitry,

I never heard back on this whether it was memory corruption bug or
not?

regards,
dan carpenter

On Thu, Sep 13, 2012 at 07:01:05PM +0300, Dan Carpenter wrote:
> Hello Dmitry Kozlov,
> 
> The patch c12b395a4664: "gre: Support GRE over IPv6" from Aug 10, 
> 2012, leads to the following warning:
> net/ipv6/ip6_gre.c:1299 ip6gre_header_parse()
> 	 error: memcpy() 'haddr' too small (8 vs 16)
> 
> net/ipv6/ip6_gre.c
>   1296  static int ip6gre_header_parse(const struct sk_buff *skb, unsigned char *haddr)
>   1297  {
>   1298          const struct ipv6hdr *ipv6h = (const struct ipv6hdr *)skb_mac_header(skb);
>   1299          memcpy(haddr, &ipv6h->saddr, sizeof(struct in6_addr));
>                        ^^^^^
> Smatch thinks this buffer is only 8 characters sometimes.
> 
>   1300          return sizeof(struct in6_addr);
>   1301  }
> 
> One call tree where this would happen would be the
> (struct sockaddr_ll *)sll->sll_addr[] in packet_rcv().
> 
> -> packet_rcv()
>    -> dev_parse_header()
>       -> ip6gre_header_parse()
> 
> I don't know the code well enough to say if this is a bug or not.  Could
> you take a look?
> 
> regards,
> dan carpenter
