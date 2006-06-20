From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH 0/2] NET: Accurate packet scheduling for ATM/ADSL
Date: Tue, 20 Jun 2006 17:09:23 +0200
Message-ID: <44980FA3.1000009@trash.net>
References: <1150278004.26181.35.camel@localhost.localdomain>	 <1150286766.5233.15.camel@jzny2>  <4497474C.4050706@trash.net> <1150815375.5270.78.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@osdl.org>, netdev@vger.kernel.org,
	lartc@mailman.ds9a.nl, russell-tcatm@stuart.id.au, hawk@diku.dk,
	Jesper Dangaard Brouer <hawk@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:41406 "EHLO
	stinky.trash.net") by vger.kernel.org with ESMTP id S1751301AbWFTPJ0
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Jun 2006 11:09:26 -0400
To: hadi@cyberus.ca
In-Reply-To: <1150815375.5270.78.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Tue, 2006-20-06 at 02:54 +0200, Patrick McHardy wrote:
> 
>>jamal wrote:
>>
>>>- For further reflection: Have you considered the case where the rate
>>>table has already been considered on some link speed in user space and
>>>then somewhere post-config the physical link speed changes? This would
>>>happen in the case where ethernet AN is involved and the partner makes
>>>some changes (use ethtool). 
>>>
> 
> [..]
> 
>>I've thought about this a couple of times, scaling the virtual clock
>>rate should be enough for "simple" qdiscs like TBF or HTB, which have
>>a linear relation between time and bandwidth. I haven't really thought
>>about the effects on HFSC yet, on a small scale the relation is
>>non-linear. 
> 
> 
> Does HFSC not depend on bandwith? How is rate control achieved?

"Depend on bandwidth" is not the right term. All of TBF, HTB and HFSC
provide bandwidth per time, but with TBF and HTB the relation between
the amount of bandwidth is linear to the amount of time, with HFSC
it is only on a linear on larger scale since it uses service curves,
which are represented as two linear pieces. So you have bandwidth b1
for time t1, bandwidth b2 after that until eternity. By scaling the
clock rate you alter after how much time b2 kicks in, which affects
the guaranteed delays. The end result should be that both bandwidth
and delay scale up or down proportionally, but I'm not sure that this
is what HFSC would do in all cases (on small scale). But it should
be easy to answer with a bit more time for visualizing it.

The thing I'm not sure about is whether this wouldn't be handled better
by userspace, if the link layer speed changes you might not want
proportional scaling but prefer to still give a fixed amount of that
bandwidth to some class, for example VoIP traffic. Do we have netlink
notifications for link speed changes?

