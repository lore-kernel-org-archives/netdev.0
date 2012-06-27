From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] tcp demux used to signal ip_route_input_noref to not
 cache dst
Date: Wed, 27 Jun 2012 01:15:36 -0700 (PDT)
Message-ID: <20120627.011536.200113758829797507.davem@davemloft.net>
References: <1340781553.10893.414.camel@edumazet-glaptop>
	<1340783533.26242.2.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40229 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751318Ab2F0IPh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jun 2012 04:15:37 -0400
In-Reply-To: <1340783533.26242.2.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 27 Jun 2012 09:52:13 +0200

> I'll test the following patch in a moment.
> 
> For the moment, set nocache to true for all frames not associated to an
> ESTABLISHED socket. Not sure we want to test SYN flag after all.

Looks good.

After this change goes in I'm going to change the calling
convention, especially since I really hate functions that
return multiple values using pass-by-reference to accomplish
this.

What I plan to do is move the early socket demux before the
skb_dst()==NULL check, then we don't need the error return.

Subsequently we can return a bool which is your new nocache
value.
