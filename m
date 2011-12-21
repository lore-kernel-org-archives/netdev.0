From: Michal Simek <monstr@monstr.eu>
Subject: Re: ICMP packets - ll_temac with Microblaze
Date: Wed, 21 Dec 2011 11:32:28 +0100
Message-ID: <4EF1B5BC.5020103@monstr.eu>
References: <4EF1B0D9.2010007@monstr.eu>	 <1324463334.2728.20.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
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
Received: from mail-ee0-f46.google.com ([74.125.83.46]:57867 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753305Ab1LUKcc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2011 05:32:32 -0500
Received: by eekc4 with SMTP id c4so7403582eek.19
        for <netdev@vger.kernel.org>; Wed, 21 Dec 2011 02:32:31 -0800 (PST)
In-Reply-To: <1324463452.2728.21.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:28 +0100, Eric Dumazet a =
=C3=A9crit :
>> Le mercredi 21 d=C3=A9cembre 2011 =C3=A0 11:11 +0100, Michal Simek a=
 =C3=A9crit :
>>> Hi Eric and David,
>>>
>>> I have found one problem with ll_temac driver and
>>> this commit: net: more accurate skb truesize
>>> sha1: 87fb4b7b533073eeeaed0b6bf7c2328995f6c075
>>>
>>> The problem is only with icmp packets from the target. It is sent a=
nd driver receive it
>>> but it is not proceed to the application.
>>>
>>> The problem I see is that kmalloc_node_track_caller allocate
>>> specific size and then this size is changed by SKB_WITH_OVERHEAD(ks=
ize(data)).
>>> The problem is with netdev_alloc_skb_ip_align which calls __alloc_s=
kb function.
>>>
>>> Currently driver uses setting for jumbo frames (9k). When I change =
it to use mtu (1,5k) then
>>> everything is ok.
>>>
>>> Can you give me some hints what can be wrong?
>>>
>> Is it with SLUB, SLAB or SLOB allocator ?
>>
>>
>=20
> (I am referring to commit bc417e30f8d
> (net: Add back alignment for size for __alloc_skb)

I have seen that commit. Using the latest&greatest version with this pa=
tch.

Michal


--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
