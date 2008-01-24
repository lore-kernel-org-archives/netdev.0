From: "Ivan H. Dichev" <idichev@obs.bg>
Subject: Slow OOM in netif_RX function
Date: Thu, 24 Jan 2008 23:18:10 +0200
Message-ID: <20080124211810.3E24A46E9A@smtp.obs.bg>
References: <4798CAA9.1080005@obs.bg>
            <4798E32E.6080003@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from obs.bg ([213.91.169.3]:41009 "EHLO smtp.obs.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753428AbYAXVSM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jan 2008 16:18:12 -0500
Received: from localhost (mail.obs.bg [127.0.0.1])
	by smtp.obs.bg (Postfix) with ESMTP id 1EC2C46E8D
	for <netdev@vger.kernel.org>; Thu, 24 Jan 2008 23:18:11 +0200 (EET)
Received: from smtp.obs.bg ([127.0.0.1])
	by localhost (mail.obs.bg [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id CeTRCcCELlqv for <netdev@vger.kernel.org>;
	Thu, 24 Jan 2008 23:18:10 +0200 (EET)
In-Reply-To: <4798E32E.6080003@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet writes:=20

> Ivan Dichev a =C3=A9crit :
>> Hello,
>> I got problem with my linux router. It has slow persistent OOM
>> problems from few months ago.
>> Every working(I mean days when more traffic is generated) day my
>> router is leaking with 15-20 MB memory and
>> after 2 weeks the restart is a MUST.
>>> From /proc/slabinfo I saw that size-2048 and size-512 are growing
>> rapidly every day when traffic occur.=20
>>=20
>> --------- /proc/slabinfo --------------------
>> size-2048          20322  20349   2072    3    2 : tunables   24  12=
    0=20
>> : slabdata   6780   6783      0
>> size-512           50984  51016    536    7    1 : tunables   32  16=
    0=20
>> : slabdata   7288   7288      0=20
>>=20
>>=20
>> I was wondering who is allocating this mem pools and then I changed
>> the kernel with 2.6.23-rc12 including  options
>> CONFIG_DEBUG_SLAB=3Dy
>> CONFIG_DEBUG_SLAB_LEAK=3Dy=20
>>=20
>>=20
>> Unfortunately changing the kernel didn't solve the mem leak....
>> Now /proc/slab_allocators is showing that 3c59x driver is allocating
>> 2048 and 512 bytes memory pools
>> caused by RX function.
>> --------- from /proc/slab_allocators ------------------------------
>> 7612 size-2048: boomerang_rx+0x33b/0x437 [3c59x]
>> 16018 size-512: boomerang_rx+0x165/0x437 [3c59x]=20
>>=20
>> I was thinking that the 3com driver is bogus, .. but not!
>> After few days I changed the cards with rtl8139 and now ....
>> --------- from /proc/slab_allocators ------------------------------
>> size-2048: 20159 rtl8139_rx+0x155/0x2dc [8139too]
>> size-1024: 2693 rtl8139_rx+0x155/0x2dc [8139too]
>> size-512: 50515 rtl8139_rx+0x155/0x2dc [8139too]=20
>>=20
>> the memory leak appear again in the same function(RX).=20
>>=20
>> I did search over the mailing list and found as similar only this
>> http://www.spinics.net/lists/kernel/old/2003-q4/msg03071.html=20
>>=20
>>=20
>> For sure it does not depend on kernel version and network
>> driver(except case if both drivers are bogus :)
>> Any ideas ?=20
>>=20
>=20
> Could you post your iptable rules "iptables -t nat -nvL ; iptables -n=
vL",=20
> and full "cat /proc/slabinfo" ?=20
>=20
>=20
=20

Sorry but my firewall is 7000+ lines and I cant paste the rules.
And that's why it's very hard to debug the chains :(=20

I have better idea!=20

What could happen if I put different Lan card in every slot?
In ex. to-private -> 3com
       to-inet    -> VIA
       to-dmz     -> rtl8139
And then to look which RX function is consuming the memory.
(boomerang_rx, rtl8139_rx, ... etc)=20

With this it will be easier to understand which iptables rules(bound to=
 the=20
found interface) have to be watched.
(I am not sure that it will work ?)=20

Any other ideas appreciated.=20

Ivan Dichev
