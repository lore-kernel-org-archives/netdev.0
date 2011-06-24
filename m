From: David Miller <davem@davemloft.net>
Subject: Re: SKB paged fragment lifecycle on receive
Date: Fri, 24 Jun 2011 12:46:24 -0700 (PDT)
Message-ID: <20110624.124624.1329947216240823992.davem@davemloft.net>
References: <4E04C961.9010302@goop.org>
	<1308938183.2532.8.camel@edumazet-laptop>
	<4E04D59B.8060301@goop.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, Ian.Campbell@citrix.com,
	netdev@vger.kernel.org, xen-devel@lists.xensource.com,
	rusty@rustcorp.com.au
To: jeremy@goop.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:36184 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752170Ab1FXTsx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jun 2011 15:48:53 -0400
In-Reply-To: <4E04D59B.8060301@goop.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeremy Fitzhardinge <jeremy@goop.org>
Date: Fri, 24 Jun 2011 11:21:15 -0700

>> Dangerous I would say. You could have a skb1 page transferred to another
>> skb2, and call skb1 destructor way before page being released.
> 
> Under what circumstances would that happen?

Pages get transferred between different SKBs all the time.

For example, GRO makes extensive use of this technique.
See net/core/skbuff.c:skb_gro_receive().

It is just one example.
