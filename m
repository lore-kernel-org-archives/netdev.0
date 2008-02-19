From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETFILTER]: Introduce nf_inet_address
Date: Tue, 19 Feb 2008 23:30:47 +0900
Message-ID: <1203431447.3223.33.camel@shinybook.infradead.org>
References: <200801291316.m0TDGivY024953@hera.kernel.org>
	 <1203428949.3223.25.camel@shinybook.infradead.org>
	 <47BAE13D.4060206@trash.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Jan Engelhardt <jengelh@computergmbh.de>,
	"David S. Miller" <davem@davemloft.net>, varekova@redhat.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:34335 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752984AbYBSOaz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2008 09:30:55 -0500
In-Reply-To: <47BAE13D.4060206@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2008-02-19 at 15:01 +0100, Patrick McHardy wrote:
> David Woodhouse wrote:
> >> +union nf_inet_addr {
> >> +	u_int32_t	all[4];
> >> +	__be32		ip;
> >> +	__be32		ip6[4];
> >> +};
> >> +
> >>  #ifdef __KERNEL__
> >>  #ifdef CONFIG_NETFILTER
> > 
> > This breaks the busybox build:
> > 
> > CC      ipsvd/tcpudp.o
> > In file included from /usr/include/linux/netfilter_ipv4.h:8,
> >                  from ipsvd/tcpudp.c:33:
> > /usr/include/linux/netfilter.h:40: error: expected specifier-qualifier-list before 'u_int32_t'
> > 
> > What is this 'u_int32_t' nonsense anyway?
> > 
> > If a user-visible header is likely to be included by libc directly from
> > a 'standard' header, it may not require <stdint.h>. Therefore it should
> > use the system-specific types such as '__u32'.
> 
> Right, I queued this patch to fix it.

That does the trick -- but are we using u_int32_t elsewhere in
user-visible headers? Does it work there? How?

> > A later commit adds struct in_addr and struct in6_addr to this union
> > too, which breaks busybox even harder.
> 
> Thats odd, the iptables headers have always used struct in_addr and
> struct in6_addr in struct ipt_ip/struct ip6t_ip6, which are also
> used by userspace. What is "ipsvd/tcpudp.c"? I couldn't find it in
> the Debian busybox source.

It's in busybox 1.9.1. Just including <netinet/in.h> seems to be
sufficient to make it happy again. I wonder if netfilter.h should
include that for itself?

-- 
dwmw2

