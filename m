From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: Tree for Aug 7
Date: Wed, 07 Aug 2013 10:47:13 -0700 (PDT)
Message-ID: <20130807.104713.1615549684239408926.davem@davemloft.net>
References: <1375892245.4004.31.camel@edumazet-glaptop>
	<1375892522.8154.3.camel@jlt4.sipsolutions.net>
	<1375893609.4004.33.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, phil@nwl.cc, sedat.dilek@gmail.com,
	sfr@canb.auug.org.au, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	hannes@stressinduktion.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:47530 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932428Ab3HGRmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Aug 2013 13:42:00 -0400
In-Reply-To: <1375893609.4004.33.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 07 Aug 2013 09:40:09 -0700

> On Wed, 2013-08-07 at 18:22 +0200, Johannes Berg wrote:
> 
>> Maybe. I haven't tested it, but I'm thinking that skb->data doesn't
>> point to the start of the data frame in this case, since we now call
>> eth_type_trans() which pulls the ethernet header. So if the device just
>> transmits skb->len starting from skb->data, it'll be wrong, no? That
>> seems a basic assumption though.
> 
> Yes, it seems calling eth_type_trans() is not right here, and even could
> crash.
> 
> Sorry, for being vague, I am a bit busy this morning.

Yes, this is absolutely the core problem, you absolute cannot
call eth_type_trans() on the output path, it pulls off the
ethernet header from the packet.  That can't possibly work.

I want a real fix submitted formally for this problem immediately,
or else I'm reverting all of these changes this afternoon.

Thanks.
