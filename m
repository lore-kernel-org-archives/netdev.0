From: "Benjamin Thery " <Benjamin.Thery@bull.net>
Subject: Re: [PATCH] net: fix /proc/net/ip_mr_cache display
Date: Mon, 01 Dec 2008 21:17:02 +0100
Message-ID: <20081201211702.a8cjo5p08wscwcwg@intran0x.frec.bull.fr>
References: <20081201160214.965805516@localhost.localdomain>
	<493415B4.7020600@bull.net> <20081201093341.537bf03d@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	DelSp=Yes	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Miller <davem@davemloft.net>,
	netdev hem <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:38619 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752146AbYLAURP convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Dec 2008 15:17:15 -0500
In-Reply-To: <20081201093341.537bf03d@extreme>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> a =E9crit=A0:

> On Mon, 01 Dec 2008 17:49:56 +0100
> Benjamin Thery <benjamin.thery@bull.net> wrote:
>
>> Argh, my patch breaks iproute2 command: ip mroute show
>>
>> iproute2 uses sscanf() to read /proc/net/ip_mr_cache and expects 6
>> fields to be read. For the unresolved entries my patch only displays
>> the first three fields. As a consequence, 'ip mroute show' skips the
>> unresolved entries. :(
>>
>> So we can
>> - either forget this patch and keep displaying garbage information
>>    in /proc/net/ip[6]_mr_cache for the unresolved entries. (No one
>>    complained before)
>> - or may be we can just print '-' or 0 for the fields that have no
>>    data associated in the unresolved case.
>>
>> Tell me what you prefer.
>>
>> Benjamin
>
> /proc file formats are part of the Linux ABI and can't change!

Yes, of course I know that. But as in this case part of the data
displayed in /proc/net/ip_mr_cache and /proc/net/ip6_mr_cache for
unresolved cache entries are complete rubbish (see the patch
description), I thought it can be improved.

The right way to fix it, IMHO, is to print 0 (zero) in the columns
that have no meaning for the unresolved entries. That way we don't
break the ABI: the userspace expects to get at least 6 numbers for
each entries, it gets 6 numbers. It's easy to figure what zeros
represent and this prevent people from wasting time trying to figure
what to do with these "random" numbers on the unresolved entries, no?


Regards,
Benjamin




>
>



----------------------------------------------------------------
This message was sent using IMP, the Internet Messaging Program.

