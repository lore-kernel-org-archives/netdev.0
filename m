From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH RESEND] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Thu, 24 Jan 2013 14:55:08 +0100
Message-ID: <20130124135508.GE16641@order.stressinduktion.org>
References: <20130123100248.GB7317@order.stressinduktion.org> <5100B1A2.3000908@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:48600 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753488Ab3AXNzJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2013 08:55:09 -0500
Content-Disposition: inline
In-Reply-To: <5100B1A2.3000908@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 24, 2013 at 12:59:30PM +0900, YOSHIFUJI Hideaki wrote:
> I need to do more research.  I am still not convinced
> to have such destination check here because the standard
> seems silent about it, and we have several basic checks
> in standard input path and tunnel search.

Thanks, looking forward to your conclusion.

> Anyway, try_6rd() can do check for prefix as well
> but we are doing slightly different thing.
> So I think we can introduce new __check_6rd() to
> return non-6rd/6to4 addresses.
> 
> bool __check_6rd(struct ip_tunnel *tunnel,
> 		 const struct in6_addr *v6dst,
> 		 __be32 *v4dst);
> 
> If prefix matches, fill *v4dst and return true.
> Otherwise, return false.
> 
> __be32 __try_6rd()
> {
> 	__be32 dst = 0;
> 	__check_6rd(tunnel, v6dst, &dst);
> 	return dst;
> }

I'll update the patch and send it over for review, thanks.
