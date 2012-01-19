From: David Miller <davem@davemloft.net>
Subject: Re: RFC Hanging clean-up of a namespace
Date: Thu, 19 Jan 2012 14:06:21 -0500 (EST)
Message-ID: <20120119.140621.817165404586593441.davem@davemloft.net>
References: <201201191207.10207.hans.schillstrom@ericsson.com>
	<20120119.124002.1964667767933832927.davem@davemloft.net>
	<20120119190114.GL2262734@jupiter.n2.diac24.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, netdev@vger.kernel.org,
	ebiederm@xmission.com
To: equinox@diac24.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:50055 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932485Ab2ASTIH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2012 14:08:07 -0500
In-Reply-To: <20120119190114.GL2262734@jupiter.n2.diac24.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Lamparter <equinox@diac24.net>
Date: Thu, 19 Jan 2012 20:01:14 +0100

> On Thu, Jan 19, 2012 at 12:40:02PM -0500, David Miller wrote:
>> From: Hans Schillstrom <hans.schillstrom@ericsson.com>
>> Date: Thu, 19 Jan 2012 12:07:09 +0100
>> 
>> > Closing of a namespace (container) can be delayed by ~ 2 minutes 
>> > due to tcp timers ex tcp time wait (and of cource other things too).
>> > 
>> > I think there should be some kind of "forced close" of the Network stack
>> > in ex free_nsproxy() 
>> 
>> I think this is unwise.
>> 
>> Keeping the timewait sockets around is necessary to absorb any lingering
>> packets in the network meant for those sockets.
>> 
>> If you truncate this activity, and then try to create another socket with
>> the same ID you'll run into the very problems time-wait is meant to
>> solve.
> 
> A network namespace is for practical matters a separate host on the
> network. Killing the namespace therefore is akin to shutting down that
> host, which on a real metal host doesn't wait for timewait sockets
> either.
> 
> Creating a socket with the same parameters would actually require
> installing a network environment similar to the closed namespace first;
> if an user really does that he can reasonably anticipate the same issues
> as arise from removing a host from the network and giving its address to
> another host.

The assumption is that the address is moving, which might not be true.
