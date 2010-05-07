From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH net-next-2.6] net: Increase NET_SKB_PAD to 64 bytes
Date: Fri, 07 May 2010 12:09:57 +0200
Message-ID: <4BE3E6F5.5050601@monstr.eu>
References: <20100506.220221.90798296.davem@davemloft.net>	 <1273209321.2222.36.camel@edumazet-laptop>	<4BE3C70C.4060705@monstr.eu>	 <20100507.013216.133893678.davem@davemloft.net>  <4BE3E1D6.30907@monstr.eu> <1273226114.2261.42.camel@edumazet-laptop>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	hadi@cyberus.ca, therbert@google.com,
	microblaze-uclinux@itee.uq.edu.au
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:60261 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754910Ab0EGKKk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 May 2010 06:10:40 -0400
Received: by fxm10 with SMTP id 10so643445fxm.19
        for <netdev@vger.kernel.org>; Fri, 07 May 2010 03:10:35 -0700 (PDT)
In-Reply-To: <1273226114.2261.42.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Le vendredi 07 mai 2010 =C3=A0 11:48 +0200, Michal Simek a =C3=A9crit=
 :
>> David Miller wrote:
>>> From: Michal Simek <monstr@monstr.eu>
>>> Date: Fri, 07 May 2010 09:53:48 +0200
>>>
>>>> I will add this Microblaze patch to my repo for testing and anyway
>>>> should go through my repo.
>>> It's already in the net-next-2.6 tree.
>> Anyway.
>>
>> I am ok with removing NET_IP_ALIGN because it is already defined in=20
>> skbuff.h to 2.
>> But increasing NET_SKB_PAD to 64 caused that Microblaze extends skb=20
>> buffers for some bytes.
>> I measured it by iperf and netperf and I see regression around 1-2Mb=
it/s=20
>> that's why I would like to ask you to revert this patch or keep at l=
east=20
>> NET_SKB_PAD part.
>=20
> Interesting.
>=20
> Increasing NET_SKB_PAD to say 128 or 256 should not have performance
> impact, but reserve a bit more ram. (truesize...)

yes. Microblaze is very sensitive on it. I have spent a couple of days=20
to find out why bandwidth is so bad and I found that truesize is the=20
problem. Whole driver allocated skb buffer to max mtu size (9000).

But if mtu is 1500 the driver still worked with max skb buffers size
Please correct me if I am wrong but if truesize is setup to 9000 then=20
net code is working with that size even if mtu is 1500.
The next thing is that cache operations take a lot of cpu cycles.

I create a patch which allocated aligned skb buffers where size depends=
=20
on current mtu size and this change rapidly increase bandwidth for=20
mtu=3D1500 from 8Mb/s to 35Mb/s (depends on setting). There is no=20
difference if jumbo frames are used (I means for driver with/without my=
=20
patch).

>=20
> Investigation is needed. Maybe your NIC now allocates high order page=
s ?
>=20
> What driver are you using ?
>=20

I am using non-mainline ll_temac driver.
drivers/net/xilinx_lltemac/

http://developer.petalogix.com/git/gitweb.cgi?p=3Dlinux-2.6-microblaze.=
git;a=3Dshortlog

Regards,
Michal




--=20
Michal Simek, Ing. (M.Eng)
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel 2.6 Microblaze Linux - http://www.monstr.eu/=
fdt/
Microblaze U-BOOT custodian
