From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 17:16:31 +0200
Message-ID: <4498114F.8090700@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>	 <1150289724.26181.74.camel@localhost.localdomain>	 <1150377383.5116.38.camel@jzny2>  <4497499F.8040507@trash.net> <1150815544.5270.82.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hawk@diku.dk, russell-tcatm@stuart.id.au, lartc@mailman.ds9a.nl,
	netdev@vger.kernel.org, Stephen Hemminger <shemminger@osdl.org>,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:23231 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751306AbWFTPQc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 11:16:32 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150815544.5270.82.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-20-06 at 03:04 +0200, Patrick McHardy wrote:
> 
>>It would be nice to have support for HFSC as well, which unfortunately
>>needs to be done in the kernel since it doesn't use rate tables.
>>What about qdiscs like SFQ (which uses the packet size in quantum
>>calculations)? I guess it would make sense to use the wire-length
>>there as well.
> 
> 
> Didnt even think of that ;-> 
> Is it getting too complicated? 

The code wouldn't be very complicated, it just adds some overhead. If
you do something like I described in my previous mail the overhead for
people not using it would be an additional pointer test before reading
skb->len. I guess we could also make it a compile time option.
I personally think this is something that really improves our quality
of implementation, after all, its "wire" resources qdiscs are meant
to manage.

> BTW, I forgot to mention one thing on the bandwidth issue is we could do
> is send netlink events on link speed changes too; some listener
> somewhere would then do the adjustment.

See the mail I just wrote :)
