From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: fe80::/64 route missing on GRE tunnels
Date: Mon, 17 Feb 2014 10:37:07 +0100
Message-ID: <5301D843.4020802@6wind.com>
References: <20140211215510.GA6994@sesse.net> <20140211215928.GA7862@sesse.net> <20140215074559.GA8634@order.stressinduktion.org> <20140215121027.GC8634@order.stressinduktion.org>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org, itk-intern@samfundet.no,
	sesse@samfundet.no,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f175.google.com ([74.125.82.175]:42832 "EHLO
	mail-we0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750939AbaBQJhK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Feb 2014 04:37:10 -0500
Received: by mail-we0-f175.google.com with SMTP id q59so10526283wes.34
        for <netdev@vger.kernel.org>; Mon, 17 Feb 2014 01:37:09 -0800 (PST)
In-Reply-To: <20140215121027.GC8634@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 15/02/2014 13:10, Hannes Frederic Sowa a =C3=A9crit :
> Hi Nicolas!
>
> On Sat, Feb 15, 2014 at 08:45:59AM +0100, Hannes Frederic Sowa wrote:
>> On Tue, Feb 11, 2014 at 10:59:28PM +0100, Steinar H. Gunderson wrote=
:
>>> On Tue, Feb 11, 2014 at 10:55:11PM +0100, Steinar H. Gunderson wrot=
e:
>>>> but on 3.13.1, no such route shows up. I can add it manually, thou=
gh.
>>>
>>> Correction; I can add it manually, but only to one GRE device at a =
time:
>>>
>>>    root@altersex:~$ ip -6 route add fe80::/64 dev k_molvenfinnoy
>>>    root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
>>>    RTNETLINK answers: File exists
>>>    root@altersex:~$ ip -6 route del fe80::/64 dev k_molvenfinnoy
>>>    root@altersex:~$ ip -6 route add fe80::/64 dev k_sessesveits
>>>    root@altersex:~$
>>
>> Sorry for the long delay, I was busy with other stuff...
>>
>> So basically a workaround you can do for the time being is to add th=
e tunnel
>> with a local address:
>>
>> ip tunnel add foo mode gre local 4.3.2.1 remote 1.2.3.4 ttl 64
>>
>> The reason is that link local address generation fails in ipv6/addrc=
onf as
>> long as dev->dev_addr is zero.
>>
>> I have not yet found the change which causes this change in behaviou=
r, but
>> will do so soon.
>
> f7cb8886335dea ("sit/gre6: don't try to add the same route two times"=
) causes
> this problem, because dev->dev_addr will never get initialized and th=
us
> ipv6_generate_eui64 and addrconf_add_linklocal will never get called.
>
> Ok for revert or do you have a better idea?
I'm not sure to understand the problem. In the case described above, th=
ere is no
fe80::/64 route because there is no link local address.
What source address will be used to communicate over this gre interface=
?
