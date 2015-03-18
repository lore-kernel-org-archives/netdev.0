From: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kv5ZCJ6Jek6Iux5piO?=
	<hideaki.yoshifuji@miraclelinux.com>
Subject: Re: [PATCH] neighbour.c: Avoid GC directly after state change
Date: Wed, 18 Mar 2015 10:56:44 +0900
Message-ID: <5508DB5C.8060207@miraclelinux.com>
References: <1426107673-45049-1-git-send-email-netdev@emagii.com> <20150312.142621.1128728353472907283.davem@davemloft.net> <5508B9E4.1060507@emagii.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: hideaki.yoshifuji@miraclelinux.com, netdev@vger.kernel.org
To: Ulf Samuelsson <netdev@emagii.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og126.obsmtp.com ([64.18.2.206]:37603 "HELO
	exprod7og126.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1754605AbbCRB4s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Mar 2015 21:56:48 -0400
Received: by mail-pa0-f50.google.com with SMTP id xg6so13594651pab.0
        for <netdev@vger.kernel.org>; Tue, 17 Mar 2015 18:56:48 -0700 (PDT)
In-Reply-To: <5508B9E4.1060507@emagii.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Ulf Samuelsson wrote:
> Den 2015-03-12 19:26, David Miller skrev:
>> I hate changes like this.
>>
>> By making this a Kconfig options it cannot be dynamic, and every
>> distribution is going to have to scratch their head and decide
>> what to set this to.
>>
>> That's seriously suboptimal.
>>
>> If you want to change behavior based upon whether userspace is
>> managing the damn table, make it so the user doing so has to
>> ask for the new behavior at _RUN TIME_ via the netlink interface
>> or similar.
>>
>> Picking the guard time itself at compile time is also undesirable.
>>
>> And you don't even want a damn timer, what you want is for the
>> state of the entry to be frozen and for the user to "release"
>> it by either adjusting the state to something else or marking
>> in some other way to allow it to be unfrozen and released again.
>>
>> Why put it to chance with some timeout?  Make things explicit.
>>
>> I'm not applying this patch.
:
> Sounds reasonable comments to me.
>
> Would this approach work?
>
> 2 new message types are defined, to enable/disable the garbage
> collection functionality.
>
> RTM_ENANEIGHGC
> RTM_DISANEIGHGC
>
>
> When the functionality is disabled, the stack will not garbage collect,
> and the external application will have to send netlink messages
> to delete unwanted entries.
>
> 1 new message is defined to move an entry from STALE to DELAY.
> RTM_NEIGHRECOVER

Why don't you "explicitly" set the neighbour, or mark the neighbour
entry as PERMANENT via netlink when you recognized that the entry
has become REACHABLE, then?

--yoshfuji
