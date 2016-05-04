From: David Miller <davem@davemloft.net>
Subject: Re: pull request (net): ipsec 2016-05-04
Date: Wed, 04 May 2016 16:48:28 -0400 (EDT)
Message-ID: <20160504.164828.439672981604295842.davem@davemloft.net>
References: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43251 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753481AbcEDUsb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 May 2016 16:48:31 -0400
In-Reply-To: <1462340454-27922-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Wed, 4 May 2016 07:40:51 +0200

> 1) The flowcache can hit an OOM condition if too
>    many entries are in the gc_list. Fix this by
>    counting the entries in the gc_list and refuse
>    new allocations if the value is too high.
> 
> 2) The inner headers are invalid after a xfrm transformation,
>    so reset the skb encapsulation field to ensure nobody tries
>    access the inner headers. Otherwise tunnel devices stacked
>    on top of xfrm may build the outer headers based on wrong
>    informations.
> 
> 3) Add pmtu handling to vti, we need it to report
>    pmtu informations for local generated packets.
> 
> Please pull or let me know if there are problems.

Pulled, thanks Steffen.

While build testing this I was worried that it might be possible
to create a situation where IP_VTI=y yet IPV6=m and therefore have
a unresolvable reference to icmpv6_send().

However I was not able to create such a configuration, as hard as
I tried. :-)
