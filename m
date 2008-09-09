From: Chris Snook <csnook@redhat.com>
Subject: Re: RFC: Nagle latency tuning
Date: Tue, 09 Sep 2008 01:22:43 -0400
Message-ID: <48C60823.9000505@redhat.com>
References: <48C59F75.6030504@redhat.com> <87ljy2tfgi.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:33944 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750861AbYIIFYW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 01:24:22 -0400
In-Reply-To: <87ljy2tfgi.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen wrote:
> Christopher Snook <csnook@redhat.com> writes:
>> I'm afraid I don't know the TCP stack intimately enough to understand
>> what side effects this might have.  Can someone more familiar with the
>> nagle implementations please enlighten me on how this could be done,
>> or why it shouldn't be?
> 
> The nagle delay you're seeing is really the delayed ack delay which
> is variable on Linux (unlike a lot of other stacks). Unfortunately
> due to the way delayed ack works on other stacks (especially traditional
> BSD with its fixed 200ms delay) there are nasty interactions with that. 
> Making it too short could lead to a lot more packets even in non nagle 
> situations.

How variable is it?  I've never seen any value other than 40 ms, from 
2.4.21 to the latest rt kernel.  I've tweaked every TCP tunable in 
/proc/sys/net/ipv4, to no effect.

The people who would care enough to tweak this would be more than happy 
to accept an increase in the number of packets.  They're usually asking 
us to disable the behavior completely, so if we can let them tune the 
middle-ground, they can test in their environments to decide what values 
their network peers will tolerate.  I have no interest in foisting this 
on the unsuspecting public.

> Ok in theory you could split the two, but that would likely have
> other issues and also make nagle be a lot less useful.

Perhaps a messaging-optimized non-default congestion control algorithm 
would be a suitable way of addressing this?

-- Chris
