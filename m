From: Ben Greear <greearb@candelatech.com>
Subject: Re: [iproute2] iproute2: Allow 'ip addr flush' to loop more than
 10 times.
Date: Tue, 29 Jun 2010 07:59:01 -0700
Message-ID: <4C2A0A35.2050403@candelatech.com>
References: <20100629095830.GA6775@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	shemminger@vyatta.com
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.candelatech.com ([208.74.158.172]:47808 "EHLO
	ns3.lanforge.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755737Ab0F2O7V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 10:59:21 -0400
In-Reply-To: <20100629095830.GA6775@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/29/2010 02:58 AM, Andreas Henriksson wrote:
> Hello all!
>
> I'm sorry if I forgot to CC someone in this reply. I'm not subscribed
> and all list archives seems to be very scared of showing recipiets
> these days.
>
> [...]
>>
>> I can understand the reasoning behind the limit, because if this is
>> run by something automated it's not like someone is at the command
>> line and hit Ctrl-C to break out of a looping instance.
>>
>> But practically speaking I bet this never happens.
>
> I'm sorry to bring bad news, but your bet is wrong!
>
> There are atleast two different places (IIRC route flush, addr flush)
> in iproute2 which have these limits because they've been preventing
> people from booting their systems in the past! I know atleast
> ubuntu users has been having problems booting their computers because
> firewalling scripts executed by init use iproute2 commands and
> expect them to finish.

First, my patch doesn't change the default behaviour, so whatever
bugs the old hack was working around, the new hack should work
around as well.

Second, these hacks were put in 4+ years ago..maybe the
underlying issues have been resolved since then? If not,
it would be good to figure out the root cause and fix it,
because having 'ip addr flush' not actually flush all the
addresses isn't much better than having it spin forever.


>> If the number of addresses increases, I think we can bail in this
>> case.
>>
>> This logic would only ever trigger iff another entity is adding a
>> large number of addresses simultaneously with our flush.  And frankly
>> speaking the person doing the flush probably doesn't expect that to be
>> happening.  You're flushing all of the addresses so you can start with
>> a clean slate and then add specific addresses back, or whatever.
>>
>
> How about implementing it in the kernel so iproute2 can tell the kernel
> via netlink "flush<addresses|routes>  on interface X" with a single
> netlink message?
> I guess the kernel side has some kind of lock here that will prevent
> addresses being added and removed at the same time?

I like this idea.  It should help with performance issues with
deleting very large numbers of addresses as well.  (I'm hoping
for 5k+ virtual IPs per interface.)

Unfortunately, I generally make a mess when trying to write such
kernel patches, but I will see if I can find someone who wants to
give it a try.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
