From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event via
 rtnetlink
Date: Wed, 05 Dec 2012 12:02:50 +0100
Message-ID: <50BF29DA.7020903@6wind.com>
References: <1354619621-16016-1-git-send-email-nicolas.dichtel@6wind.com> <20121204.130914.1457976839967676240.davem@davemloft.net> <50BE56D3.2030704@6wind.com>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:33819 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752549Ab2LELCy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 06:02:54 -0500
Received: by mail-bk0-f46.google.com with SMTP id q16so2067055bkw.19
        for <netdev@vger.kernel.org>; Wed, 05 Dec 2012 03:02:53 -0800 (PST)
In-Reply-To: <50BE56D3.2030704@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 04/12/2012 21:02, Nicolas Dichtel a =E9crit :
> Le 04/12/2012 19:09, David Miller a =E9crit :
>> From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>> Date: Tue,  4 Dec 2012 12:13:34 +0100
>>
>>> The goal of this serie is to be able to monitor multicast activitie=
s via
>>> rtnetlink.
>>>
>>> The main changes are:
>>>   - when user dumps mfc entries it now get all entries, included th=
e unresolved
>>>     cache.
>>>   - kernel sends rtnetlink when it adds/deletes mfc entries.
>>>
>>> As usual, the patch against iproute2 will be sent once the patches =
are
>>> included and
>>> net-next merged. I can send it on demand.
>>
>> This looks good, applied, thanks Nicolas.
>>
>> The one thing I worry about are those 64-bit statistics.  I fear tha=
t they
>> not be 64-bit aligned in the final netlink message.  This matters on=
 cpus
>> that trap on unaligned loads/stores, such as sparc and MIPS.
>>
>> Can you validate this?
>>
> I can have a try on a tile platform. I don't have access to sparc or =
mips.
Hmm, I've read arm instead of mips! So I've tried on mips. Data are ali=
gned on=20
32-bit, like for all netlink messages. nla_put_u64() will do the same, =
as it=20
calls nla_put().

And the kernel will only use memcpy() to treat this attribute. Reader w=
ill be in=20
userland.
