From: Krzysztof Oledzki <olel@ans.pl>
Subject: Re: Wrong padding of short packets send by a tagged-vlan interface?
Date: Mon, 7 Jul 2008 23:40:58 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0807072337320.15459@bizon.gios.gov.pl>
References: <Pine.LNX.4.64.0807072210470.15459@bizon.gios.gov.pl>
 <4872854C.201@trash.net>
Mime-Version: 1.0
Content-Type: MULTIPART/MIXED; BOUNDARY="-187430788-157067279-1215466858=:15459"
Cc: netdev@vger.kernel.org, greearb@candelatech.com
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([212.244.124.8]:60586 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758659AbYGGVli (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 17:41:38 -0400
In-Reply-To: <4872854C.201@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  This message is in MIME format.  The first part should be readable text,
  while the remaining parts are likely unreadable without MIME-aware tools.

---187430788-157067279-1215466858=:15459
Content-Type: TEXT/PLAIN; charset=ISO-8859-2; format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE



On Mon, 7 Jul 2008, Patrick McHardy wrote:

> Krzysztof Oledzki wrote:
>> Hello,
>>=20
>> I have a problem that I'm not able to connect from selected linux hosts =
to=20
>> a newly installed Netware 6.5 server. After two days of debugging I=20
>> discovered that the problem seems to be caused by an insufficient paddin=
g=20
>> of a .1q tagged packets.
>>=20
>> Currently, if a packet is too short, it is extended to 60(+4) octets for=
=20
>> both untagged and tagged ones. Unfortunately, when a .1Q tag is removed =
on=20
>> a receive side, such packet is likely to be dropped as it may become too=
=20
>> short (56 bytes):
>>=20
>> This is a normal (working) ping with 84B (IP) + 14B (eth hdr) =3D 98B oc=
tets:
>> # ping -c 2 192.168.0.194
>> PING 192.168.0.194 (192.168.0.194) 56(84) bytes of data.
>> 64 bytes from 192.168.0.194: icmp_seq=3D1 ttl=3D128 time=3D0.137 ms
>> 64 bytes from 192.168.0.194: icmp_seq=3D2 ttl=3D128 time=3D0.141 ms
>>=20
>> This is a shorter (working) ping with 46 (IP) + 14B (eth hdr) =3D 60B oc=
tets:
>> # ping -c 2 192.168.0.194 -s 18
>> PING 192.168.0.194 (192.168.0.194) 18(46) bytes of data.
>> 26 bytes from 192.168.0.194: icmp_seq=3D1 ttl=3D128 time=3D0.137 ms
>> 26 bytes from 192.168.0.194: icmp_seq=3D2 ttl=3D128 time=3D0.144 ms
>>=20
>> This one does not work (45+14 =3D 59): # ping -c 2 192.168.0.194 -s 17
>> PING 192.168.0.194 (192.168.0.194) 17(45) bytes of data.
>>=20
>> --- 192.168.0.194 ping statistics ---
>> 2 packets transmitted, 0 received, 100% packet loss, time 999ms
>>=20
>> I believe that my problem can be solved if we start padding .1Q packets=
=20
>> with 4 more octets but I'm not able to find a proper place where to fix =
it.
>
> Nice catch, if this really is the problem :) For a fix I'd suggest to
> add a skb_ether_pad() function that performs the necessary padding
> depending on skb->protocol and change the ethernet drivers to use it
> instead of skb_padto().

Not all drivers use skb_padto:

# grep skb_padto -R e1000 e1000e bnx*.c
(empty)

Any idea where to change it in the above ones?

Best regards,

 =09=09=09=09Krzysztof Ol=EAdzki
---187430788-157067279-1215466858=:15459--
