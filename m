From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [RFC PATCH 0/2] remove netpoll rx support
Date: Tue, 11 Mar 2014 12:48:30 -0700
Message-ID: <87wqg0cy9d.fsf@xmission.com>
References: <20140311.004217.1616529960369263682.davem@davemloft.net>
	<1394514158.21721.7.camel@edumazet-glaptop2.roam.corp.google.com>
	<87a9cxf7mp.fsf_-_@xmission.com>
	<20140311.124907.1180556684992271103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Cc: eric.dumazet@gmail.com, netdev@vger.kernel.org,
	xiyou.wangcong@gmail.com, mpm@selenic.com, satyam.sharma@gmail.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:32861 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755079AbaCKTsh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Mar 2014 15:48:37 -0400
In-Reply-To: <20140311.124907.1180556684992271103.davem@davemloft.net> (David
	Miller's message of "Tue, 11 Mar 2014 12:49:07 -0400 (EDT)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> writes:

> From: ebiederm@xmission.com (Eric W. Biederman)
> Date: Tue, 11 Mar 2014 01:43:10 -0700
>
>> Furthermore netpoll by it's design depends on the ability to receive
>> packets in netpoll_poll_dev.  It is a capability I don't think we have
>> ever used in the mainline kernel but it is a capability that is there
>> deliberately.  Which means if we want netpoll to not mess with the rx
>> path we need to change netpoll.
>
> This breaks kdump, and any other users of netpoll_rx() et al.

It does not break kdump.  (kdump starts a new kernel to do it's work). 

It does break the ancient lkcd netdump that was never merged, and has
been abandoned (to the best of my knowledge). crash dumps proved
entirely too fragile to perform from a broken kernel.

It does break kgdboe that was never merged.

> Make the zero budget depend upon us being invoked from hardware
> irq context, or something like that.

Good enough.  I will respin my driver patches based on the assumption
that netpoll will be changed in this way.  There are no dependencies
for the drivers, I just need to remove my rx path changes.

We can have the conversation about how to change netpoll in parallel.

Eric
