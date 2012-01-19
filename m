From: David Miller <davem@davemloft.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 15:27:52 -0500 (EST)
Message-ID: <20120119.152752.318442465605898328.davem@davemloft.net>
References: <20120119192541.GM2262734@jupiter.n2.diac24.net>
	<20120119.143105.735366189369504929.davem@davemloft.net>
	<20120119195349.GN2262734@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50663 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932751Ab2ASU3i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 15:29:38 -0500
In-Reply-To: <20120119195349.GN2262734@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Thu, 19 Jan 2012 20:53:49 +0100

> On Thu, Jan 19, 2012 at 02:31:05PM -0500, David Miller wrote:
>> >> >> Keeping the timewait sockets around is necessary to absorb any lingering
>> >> >> packets in the network meant for those sockets.
> [...]
>> >> The assumption is that the address is moving, which might not be true.
>> > 
>> > I don't understand what you mean, what address may not be moving?
>> > 
>> > We're talking about dropping a netns. All of its addresses disappear,
>> > all of its soft devices disappear. Its hard devices fall back into the
>> > init namespace, is that what you're referring to?
>> 
>> And then you immediately start up a new netns with the same address
>> and then resets go back to lingering TCP packets the time-waits would
>> have consumed.
>> 
>> The reason this is different from a host reboot is that a host reboot
>> takes some amount of time, which even if around 30 seconds is superior
>> in behavior to what can happen with netns which can be created almost
>> instantly.
> 
> Arjan van de Ven booted Linux in 5 seconds in 2008,
> cf. http://lwn.net/Articles/299483/
> 
> On the TCP timewait scale of time, this is pretty much "immediate".
> 
> [..]
>> Then if a new netns is created that tries to reuse the address used by
>> the mini-netns which hasn't cleared yet, you give -EAGAIN until all
>> the timewaits expire.
> 
> The effect of this is that you end up being unable to reboot lxc based
> virtualised hosts without waiting 2 minutes for the TCP timers to
> expire. That sounds completely unacceptable to me.

All you are saying to me is that we are on a trajectory to major problems
if it becomes pervasive that time-wait gets cancelled out and addresses
then get reused so quickly.
