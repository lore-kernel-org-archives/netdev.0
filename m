From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] ipv6: add anti-spoofing checks for 6to4 and 6rd
Date: Tue, 22 Jan 2013 09:20:28 +0100
Message-ID: <20130122082028.GB7865@order.stressinduktion.org>
References: <20130118200416.GB4795@order.stressinduktion.org> <50F9F875.30302@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:43580 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751466Ab3AVIU3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 03:20:29 -0500
Content-Disposition: inline
In-Reply-To: <50F9F875.30302@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On Sat, Jan 19, 2013 at 10:35:49AM +0900, YOSHIFUJI Hideaki wrote:
> It seems this breaks 6rd receiving rules:
> 
> BR:
> 	if (outer src ip4 != embedded src ip4)
> 		drop();

Of course, this would break 6rd as would it break 6to4. Note here, that
I also check for the inner ipv6 prefix. This check is only done, if the
inner ipv6 prefix matches a) the 6to4 prefix or b) the 6rd prefix. In 6rd,
as in 6to4, communication between 6rd nodes should take place directly,
without need for a relay. (Otherwise packets would get dropped, because
both source and destination ipv6 address would be in the 6rd/6to4 prefix
and the ipv4 addresses would not match, because one of them would be
the relay address.)

> CE:
> 	if (outer src ip4 != embedded src ip4 ||
> 	    inner dest ip6 != configured ip6 prefix)
> 		drop();

Dito, would also break 6to4. Every packet from non-6rd domain would
violate this rule. I do also check the 6rd/6to4 prefix in this case.

In general, if the inner ipv6 address, regardless of source or
destination, does not match the 6rd/6to4 prefix, the packet will pass
without further checks from my patch.

> 
> No?

I think that the distinction between BR and CE would make thinks just
more complicated. Also 6rd can be seen as a superset of 6to4 and should
not make any changes to the receiving rules, except being more tight.

Thanks,

  Hannes
