From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Mon, 04 Aug 2014 12:42:46 -0700 (PDT)
Message-ID: <20140804.124246.819301748264471598.davem@davemloft.net>
References: <CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
	<20140803.212131.1256448650945676000.davem@davemloft.net>
	<CALnjE+oEKGakFMZvSBir3OUmMdQmZdF2+YEy5kDV=P=_BNKU4Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750714AbaHDTmr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 15:42:47 -0400
In-Reply-To: <CALnjE+oEKGakFMZvSBir3OUmMdQmZdF2+YEy5kDV=P=_BNKU4Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Mon, 4 Aug 2014 12:35:59 -0700

> On Sun, Aug 3, 2014 at 9:21 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin Shelar <pshelar@nicira.com>
>> Date: Sun, 3 Aug 2014 12:20:32 -0700
>>
>>> On Sat, Aug 2, 2014 at 3:16 PM, David Miller <davem@davemloft.net> wrote:
>>>> From: Pravin B Shelar <pshelar@nicira.com>
>>>> Date: Thu, 31 Jul 2014 16:57:37 -0700
>>>>
>>>>> Following patch adds mask cache so that we do not need to iterate over
>>>>> all entries in mask list on every packet. We have seen good performance
>>>>> improvement with this patch.
>>>>
>>>> How much have you thought about the DoS'ability of openvswitch's
>>>> datastructures?
>>>>
>>> This cache is populated by flow lookup in fast path. The mask cache is
>>> fixed in size. Userspace or number of packets can not change its size.
>>> Memory is statically allocated, no garbage collection. So DoS attack
>>> can not exploit this cache to increase ovs memory footprint.
>>
>> An attacker can construct a packet sequence such that every mask cache
>> lookup misses, making the cache effectively useless.
> 
> Yes, but it does work in normal traffic situations.

You're basically just reiterating the point I'm trying to make.

Your caches are designed for specific configuration and packet traffic
pattern cases, and can be easily duped into a worse case performance
scenerio by an attacker.

Caches, basically, do not work on the real internet.

Make the fundamental core data structures fast and scalable enough,
rather than bolting caches (which are basically hacks) on top every
time they don't perform to your expectations.

What if you made the full flow lookup fundamentally faster?  Then an
attacker can't do anything about that.  That's a real performance
improvement, one that sustains arbitrary traffic patterns.
