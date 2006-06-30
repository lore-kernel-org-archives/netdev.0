From: Ben Greear <greearb@candelatech.com>
Subject: Re: [PATCH 2/3] [VLAN]: Update iif when receiving via VLAN device
Date: Fri, 30 Jun 2006 08:40:00 -0700
Message-ID: <44A545D0.6060504@candelatech.com>
References: <20060628130124.GX1376@postel.suug.ch>	 <1151502408.5203.94.camel@jzny2> <20060629085111.GY1376@postel.suug.ch>	 <1151623394.8922.27.camel@jzny2> <20060629233933.GB14627@postel.suug.ch>	 <1151625826.8922.58.camel@jzny2> <20060630004640.GC14627@postel.suug.ch>	 <1151629890.8922.121.camel@jzny2> <20060630130811.GE14627@postel.suug.ch>	 <1151675843.5270.18.camel@jzny2>  <20060630141531.GG14627@postel.suug.ch> <1151678118.5270.45.camel@jzny2>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:32997 "EHLO ns2.lanforge.com")
	by vger.kernel.org with ESMTP id S1750804AbWF3Pkn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jun 2006 11:40:43 -0400
To: hadi@cyberus.ca
In-Reply-To: <1151678118.5270.45.camel@jzny2>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

jamal wrote:
> On Fri, 2006-30-06 at 16:15 +0200, Thomas Graf wrote:

>>You agreed in
>>your last posting that the 3rd option, being that not caring about
>>whether a device might disappear but having a way to check for it,
>>is what we agreed on and what makes most sense, 
> 
> 
> yes, i recalled that as the last discussion we had.
> 
> 
>>yet you fail to see
>>that using ifindex is exactly what reflects this descision.
>>
> 
> 
> The choice is between using an ifindex and a pointer to the device. 
> Why is it solvable via an ifindex but not a device pointer?
> I may have misunderstood you, so look at this as a fresh opportunity to
> enlighten me. Forget about all the discussion weve had thus far.

If you use a pointer, without taking it's reference, then that device
can go away, and leave you with a stale memory access, ie kernel crash
or worse.

If you take a reference for every packet (which means an atomic op), then
you slow down every packet, even those that will never use the reference.

If you instead use the if-index, then you do not need to take a reference
for every packet, but only when you actually want to look at that device.
If the device has since disappeared, then you get a null when trying to find
by reference, and the code can take appropriate action.  No chance for
access of stale memory.

Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

