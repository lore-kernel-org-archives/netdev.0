From: Michal Simek <monstr@monstr.eu>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:30:47 +0100
Message-ID: <4EF1B557.3050901@monstr.eu>
References: <4EF1B0D9.2010007@monstr.eu> <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	John Williams <john.williams@petalogix.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:41699 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753436Ab1LUKat (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:30:49 -0500
Received: by eekc4 with SMTP id c4so7402488eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:30:48 -0800 (PST)
In-Reply-To: <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:11 +0100, Michal Simek a =
=C3=A9crit :
>> Hi Eric and David,
>>
>> I have found one problem with ll_temac driver and
>> this commit: net: more accurate skb truesize
>> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
>>
>> The problem is only with icmp packets from the target. It is sent an=
d driver receive it
>> but it is not proceed to the application.
>>
>> The problem I see is that kmalloc_node_track_caller allocate
>> specific size and then this size is changed by SKB_WITH_OVERHEAD(ksi=
ze(data)).
>> The problem is with netdev_alloc_skb_ip_align which calls __alloc_sk=
b function.
>>
>> Currently driver uses setting for jumbo frames (9k). When I change i=
t to use mtu (1,5k) then
>> everything is ok.
>>
>> Can you give me some hints what can be wrong?
>>
>=20
> Is it with SLUB, SLAB or SLOB allocator ?

SLAB.

CONFIG_SLAB=3Dy
# CONFIG_SLUB is not set
# CONFIG_SLOB is not set

Michal


--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
