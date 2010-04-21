From: Franco Fichtner <franco@lastsummer.de>
Subject: Re: [PATCH net-next-2.6] rps: consistent rxhash
Date: Wed, 21 Apr 2010 11:29:55 +0200
Message-ID: <4BCEC593.4000007@lastsummer.de>
References: <1271452358.16881.4486.camel@edumazet-laptop>	 <1271520633.16881.4754.camel@edumazet-laptop>	 <20100419.130905.210660275.davem@davemloft.net>	 <20100419.132318.192086187.davem@davemloft.net>	 <1271709121.3845.94.camel@edumazet-laptop>	 <y2u412e6f7f1004191638mee9206dfoab7482bbff83e38d@mail.gmail.com>	 <1271743164.3845.128.camel@edumazet-laptop>	 <1271750198.3845.216.camel@edumazet-laptop>	 <4BCDA2B5.4060609@lastsummer.de> <i2q65634d661004200809ydba56c35g785ba51900c379f7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from host64.kissl.de ([213.239.241.64]:42849 "EHLO host64.kissl.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753663Ab0DUJ37 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 05:29:59 -0400
In-Reply-To: <i2q65634d661004200809ydba56c35g785ba51900c379f7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Tom Herbert wrote:
>> I thought about this for some time...
>>
>> Do we really need the port numbers here at all? A simple
>> addr1^addr2 can provide a good enough pointer for
>> distribution amongst CPUs.
>>
> 
> What about a server behind a TCP proxy?  Also, need to minimize
> collisions for RPS to be effective

What about routers? What about loopback? This all boils down to
the same issue of obscuring IP data by "magical" means and then
reattaching functionality by reaching for upper layer information.
It is necessary in some cases, but it can cripple performance
for other cases.

The interesting thing is you don't need to deal with collisions
while distributing amonst cpus at all. You just need to make sure
the distribution algorithm keeps every single flow attached to
the correct cpu.

All of the actual flow hashing, tracking and whatever else the
traffic needs to go through can be done locally by cpu x which
helps a lot with load distribution and cache issues in mind. It
also helps locking because there is no global flow lookup table.
Oh, and it also reduces collisions with every cpu you add for
receiving.

I work with a lot of plain office and ISP traffic in mind daily,
so please don't misunderstand my motivation here. I'd hate to
see poor performance in scenarios in which there is a lot of
potential improvement.


Franco
