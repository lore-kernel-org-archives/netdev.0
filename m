From: Mitar <mmitar@gmail.com>
Subject: Re: Ethernet-over-UDP virtual network interface
Date: Sun, 4 Mar 2012 14:58:22 +0100
Message-ID: <CAKLmikMEbyq8LRRyyJTL76vG6ibPs4=dThqa0PJxd7WHk4m82A@mail.gmail.com>
References: <CAKLmikOBPB7rTZu2EfK26=3AhOQUR8xg8n4ySUKRMFmBkC1J3g@mail.gmail.com>
	<5a14e44a83a6de3788da96367f982a73@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Nejc Skoberne <nejc@skoberne.net>,
	Jernej Kos <kostko@unimatrix-one.org>, gw.2012@tnode.com
To: Denys Fedoryshchenko <denys@visp.net.lb>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:48336 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754359Ab2CDN6W convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Mar 2012 08:58:22 -0500
Received: by vbbff1 with SMTP id ff1so2730717vbb.19
        for <netdev@vger.kernel.org>; Sun, 04 Mar 2012 05:58:22 -0800 (PST)
In-Reply-To: <5a14e44a83a6de3788da96367f982a73@visp.net.lb>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

The problem of GRE IP packets (IP protocol type 47) is that some
consumer routers filter them by default (or even do not have an option
to pass them through).

Maybe the best way would be just to implement greudptap link type
which would be the same as gretap, only it would be using UDP packets?
Do Linux bridge interfaces have MAC auto-discovery?

Do Linux gretap tunnels have MTU auto-discovery?

BTW, why is necessary to configure local IP address of the tunnel?
Shouldn't only a local MAC address be enough? And IP address only on
bridge interface?


Mitar

On Sun, Mar 4, 2012 at 1:21 PM, Denys Fedoryshchenko <denys@visp.net.lb=
> wrote:
> From my wiki :)
> ip link add eoip1 type gretap remote IP1 local IP2 nopmtudisc
> ifconfig eth1 0.0.0.0
> ifconfig eoip1 mtu 1500 up
> brctl addbr br0
> brctl addif br0 eoip1
> brctl addif br0 eth1
> ifconfig br0 up
>
> But not sure this will work, just a hint for kernel-mode tunnel
>
>
>
> On 2012-03-04 13:30, Mitar wrote:
>>
>> Hi!
>>
>> At community wireless network wlan slovenija (http://dev.wlan-si.net=
/)
>> we have been using OpenVPN tunnels to connect our WiFi nodes togethe=
r
>> over existing Internet infrastructure. After some time of using it w=
e
>> have discovered throughput problems using a user-land tunneling
>> solution on those small/consumer Wifi router hardware. Because of th=
e
>> context switches we cannot get more than 5 Mbit/s even with disabled
>> encryption. (And as we have a lot of fiber here, it really makes
>> uplinks unused a lot.)
>>
>> We found out that we need a really light-weight tunneling solution,
>> but on a L2 level. The idea is to have a simple encryption-less,
>> state-less, and session-less L2 tunneling. Some kind of
>> Ethernet-over-UDP type of virtual interface where we could configure
>> multiple peer IP address and virtual interface would work as a simpl=
e
>> switch, only instead of cables, it would send packets encapsulated i=
n
>> UDP (EoIP is not good because many consumer routers do not allow
>> non-TCP/UDP packets to get through). No session handling, nothing.
>> Simply, any packets it gets in it is send (based on auto-learned MAC
>> addresses) to the destination IP address in the UDP packet. On the
>> other side decapsulated packet is simply output of the virtual
>> interface there.
>>
>> I have searched around and have not found anything which would work
>> like this. Have I missed something? If not, I have decided to write
>> our own kernel module for this, but first I would like to hear some
>> feedback from others. Would anybody be interested in developing it
>> with me or at mentoring me (it would be my first kernel module)?
>>
>> I have found this code:
>>
>> https://lwn.net/Articles/199120/
>>
>> and was planning to use it as a basis, but use UDP for communication=
=2E
>> What is a proper way to do UDP communication from a kernel module?
>>
>> Best regards and thank you all for the great work you are doing on L=
inux
>>
>>
>> Mitar
>> --
>> To unsubscribe from this list: send the line "unsubscribe netdev" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at =C2=A0http://vger.kernel.org/majordomo-info.h=
tml
>
>
>
