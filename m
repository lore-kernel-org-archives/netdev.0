From: David Miller <davem@davemloft.net>
Subject: Re: new ipdelay= option for faster netboot
Date: Mon, 17 Aug 2009 18:56:14 -0700 (PDT)
Message-ID: <20090817.185614.267314151.davem@davemloft.net>
References: <4A8A02CA.7040305@am.sony.com>
	<20090817.182754.50348941.davem@davemloft.net>
	<4A8A06A0.2070402@am.sony.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: r.schwebel@pengutronix.de, vda.linux@googlemail.com,
	linux-kernel@vger.kernel.org, linux-embedded@vger.kernel.org,
	arjan@linux.intel.com, kernel@pengutronix.de,
	netdev@vger.kernel.org
To: tim.bird@am.sony.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1758611AbZHRB4F@vger.kernel.org>
In-Reply-To: <4A8A06A0.2070402@am.sony.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Tim Bird <tim.bird@am.sony.com>
Date: Mon, 17 Aug 2009 18:40:48 -0700

> David Miller wrote:
>> From: Tim Bird <tim.bird@am.sony.com>
>> Date: Mon, 17 Aug 2009 18:24:26 -0700
>>
>>> David Miller wrote:
>>>> I have card/switch combinations that take up to 10 seconds to
>>>> negotiate a proper link.
>>> What types of delays are these timeouts supposed to
>>> cover?
>>
>> The problem is that if you don't first give at least some time for the
>> link to come up, the remaining time it takes the link to come up will
>> end up chewing into the actual bootp/dhcp protocol timeouts.  And
>> that's what we're trying to avoid.
> 
> What link?  I'm not that familiar with networking.

The speed and duplex settings which are negotiated or forced between
the ethernet card and whatever is at the other end of the cable.

> Assuming I'm using ethernet, what link needs to come up?

All modern ethernet cards do autonegotiation of link parameters
with whatever is at the other end of the ethernet cable.  Cards
created ages ago which only support 10MB half-duplex typically
do not support autonegotiation at all.

This autonegotiation works like a protocol where the two link partners
go back and forth trying to figure out the best speed and duplex
settings to use.  There are advertisements of link capabilities and
stuff like that.

It should happen almost instantaneously, but there are millions
upon millions of cruddy parts out there, and some of them take
a long time to go through this negotiation process.
