From: Pravin Shelar <pshelar@nicira.com>
Subject: Re: [GIT net-next] Open vSwitch
Date: Mon, 4 Aug 2014 12:35:59 -0700
Message-ID: <CALnjE+oEKGakFMZvSBir3OUmMdQmZdF2+YEy5kDV=P=_BNKU4Q@mail.gmail.com>
References: <1406851057-1593-1-git-send-email-pshelar@nicira.com>
	<20140802.151630.929949940730781279.davem@davemloft.net>
	<CALnjE+rAXDpzkL9H9EAHKZ0yGCW3HHu+LgihwOj5Yx_5SASzsA@mail.gmail.com>
	<20140803.212131.1256448650945676000.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from na6sys009bog032.obsmtp.com ([74.125.150.106]:59994 "HELO
	na6sys009bog032.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751727AbaHDTgA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Aug 2014 15:36:00 -0400
Received: by mail-ie0-f179.google.com with SMTP id rl12so10308186iec.24
        for <netdev@vger.kernel.org>; Mon, 04 Aug 2014 12:35:59 -0700 (PDT)
In-Reply-To: <20140803.212131.1256448650945676000.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Aug 3, 2014 at 9:21 PM, David Miller <davem@davemloft.net> wrote:
> From: Pravin Shelar <pshelar@nicira.com>
> Date: Sun, 3 Aug 2014 12:20:32 -0700
>
>> On Sat, Aug 2, 2014 at 3:16 PM, David Miller <davem@davemloft.net> wrote:
>>> From: Pravin B Shelar <pshelar@nicira.com>
>>> Date: Thu, 31 Jul 2014 16:57:37 -0700
>>>
>>>> Following patch adds mask cache so that we do not need to iterate over
>>>> all entries in mask list on every packet. We have seen good performance
>>>> improvement with this patch.
>>>
>>> How much have you thought about the DoS'ability of openvswitch's
>>> datastructures?
>>>
>> This cache is populated by flow lookup in fast path. The mask cache is
>> fixed in size. Userspace or number of packets can not change its size.
>> Memory is statically allocated, no garbage collection. So DoS attack
>> can not exploit this cache to increase ovs memory footprint.
>
> An attacker can construct a packet sequence such that every mask cache
> lookup misses, making the cache effectively useless.

Yes, but it does work in normal traffic situations. I have posted
performance numbers in the cover letter.
Under DoS attack as you said attacker need to build sequence of
packets to make cache ineffective. Which results in cache miss and a
full in-kernel flow lookup. Therefore with this cache there is one
more lookup done under DoS. But this is not very different than
current OVS anyways.
