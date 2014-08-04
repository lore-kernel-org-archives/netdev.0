From: David Miller <davem@davemloft.net>
Subject: Re: [GIT net-next] Open vSwitch
Date: Sun, 03 Aug 2014 21:21:31 -0700 (PDT)
Message-ID: <20140803.212131.1256448650945676000.davem@davemloft.net>
References: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
	<20140802.151630.929949940730781279.davem@davemloft.net>
	<CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750892AbaHDEVd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 00:21:33 -0400
In-Reply-To: <CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pravin Shelar <pshelar@nicira.com>
Date: Sun, 3 Aug 2014 12:20:32 -0700

> On Sat, Aug 2, 2014 at 3:16 PM, David Miller <davem@davemloft.net> wrote:
>> From: Pravin B Shelar <pshelar@nicira.com>
>> Date: Thu, 31 Jul 2014 16:57:37 -0700
>>
>>> Following patch adds mask cache so that we do not need to iterate over
>>> all entries in mask list on every packet. We have seen good performance
>>> improvement with this patch.
>>
>> How much have you thought about the DoS'ability of openvswitch's
>> datastructures?
>>
> This cache is populated by flow lookup in fast path. The mask cache is
> fixed in size. Userspace or number of packets can not change its size.
> Memory is statically allocated, no garbage collection. So DoS attack
> can not exploit this cache to increase ovs memory footprint.

An attacker can construct a packet sequence such that every mask cache
lookup misses, making the cache effectively useless.
