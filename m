From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current device token
Date: Fri, 08 Apr 2016 17:25:37 +0200
Message-ID: <874mbct95a.fsf@nemi.mork.no>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net>
	<878u0otc96.fsf@nemi.mork.no>
	<1460126038.1452331.572938089.68D8127C@webmail.messagingengine.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net,
	robbat2@gentoo.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:57472 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758180AbcDHP0D convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 11:26:03 -0400
In-Reply-To: <1460126038.1452331.572938089.68D8127C@webmail.messagingengine.com>
	(Hannes Frederic Sowa's message of "Fri, 08 Apr 2016 16:33:58 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hannes Frederic Sowa <hannes@stressinduktion.org> writes:

> On Fri, Apr 8, 2016, at 16:18, Bj=C3=B8rn Mork wrote:
>> Daniel Borkmann <daniel@iogearbox.net> writes:
>>=20
>> > =20
>> >  	if (!token)
>> >  		return -EINVAL;
>> > -	if (ipv6_addr_any(token))
>> > -		return -EINVAL;
>> >  	if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
>> >  		return -EINVAL;
>>=20
>> Not directly related to the patch in question.  It just made me awar=
e of
>> this restriction...
>>=20
>> I realize that I'm a few years late here, but what's with the IFF_NO=
ARP?
>> Is that just because we can't do DAD for the token based addresses? =
 How
>> is that different from manually configuring the whole address?
>
> IFF_NOARP is kind of the equivalent to no neighbor discovery. If you =
set
> a token and never get in a router advertisement you never create a
> tokenized ip address, thus the feature is useless.

You can get router advertisements with IFF_NOARP. You cannot lookup L2
addresses, but the L3 prefix info is still as useful as with any other
interface.

Doing

 tshark -nVi any -f ip6

while bringing up the POINTOPOINT NOARP interface shown at the end show=
s
the expected RS and RA:

=46rame 1: 64 bytes on wire (512 bits), 64 bytes captured (512 bits) on=
 interface 0
    Interface id: 0 (any)
    Encapsulation type: Linux cooked-mode capture (25)
    Arrival Time: Apr  8, 2016 17:18:36.094554456 CEST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 1460128716.094554456 seconds
    [Time delta from previous captured frame: 0.000000000 seconds]
    [Time delta from previous displayed frame: 0.000000000 seconds]
    [Time since reference or first frame: 0.000000000 seconds]
    Frame Number: 1
    Frame Length: 64 bytes (512 bits)
    Capture Length: 64 bytes (512 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: sll:ethertype:ipv6:icmpv6]
Linux cooked capture
    Packet type: Sent by us (4)
    Link-layer address type: 65534
    Link-layer address length: 0
    Protocol: IPv6 (0x86dd)
Internet Protocol Version 6, Src: fe80::8019:47ef:17a1:8c38, Dst: ff02:=
:2
    0110 .... =3D Version: 6
    .... 0000 0000 .... .... .... .... .... =3D Traffic class: 0x00 (DS=
CP: CS0, ECN: Not-ECT)
        .... 0000 00.. .... .... .... .... .... =3D Differentiated Serv=
ices Codepoint: Default (0)
        .... .... ..00 .... .... .... .... .... =3D Explicit Congestion=
 Notification: Not ECN-Capable Transport (0)
    .... .... .... 0000 0000 0000 0000 0000 =3D Flowlabel: 0x00000000
    Payload length: 8
    Next header: ICMPv6 (58)
    Hop limit: 255
    Source: fe80::8019:47ef:17a1:8c38
    Destination: ff02::2
    [Source GeoIP: Unknown]
    [Destination GeoIP: Unknown]
Internet Control Message Protocol v6
    Type: Router Solicitation (133)
    Code: 0
    Checksum: 0x1155 [correct]
    Reserved: 00000000

=46rame 2: 120 bytes on wire (960 bits), 120 bytes captured (960 bits) =
on interface 0
    Interface id: 0 (any)
    Encapsulation type: Linux cooked-mode capture (25)
    Arrival Time: Apr  8, 2016 17:18:36.101806992 CEST
    [Time shift for this packet: 0.000000000 seconds]
    Epoch Time: 1460128716.101806992 seconds
    [Time delta from previous captured frame: 0.007252536 seconds]
    [Time delta from previous displayed frame: 0.007252536 seconds]
    [Time since reference or first frame: 0.007252536 seconds]
    Frame Number: 2
    Frame Length: 120 bytes (960 bits)
    Capture Length: 120 bytes (960 bits)
    [Frame is marked: False]
    [Frame is ignored: False]
    [Protocols in frame: sll:ethertype:ipv6:icmpv6]
Linux cooked capture
    Packet type: Unicast to us (0)
    Link-layer address type: 65534
    Link-layer address length: 0
    Protocol: IPv6 (0x86dd)
Internet Protocol Version 6, Src: fe80::a5a6:793:6bfe:ea1c, Dst: fe80::=
8019:47ef:17a1:8c38
    0110 .... =3D Version: 6
    .... 0000 0000 .... .... .... .... .... =3D Traffic class: 0x00 (DS=
CP: CS0, ECN: Not-ECT)
        .... 0000 00.. .... .... .... .... .... =3D Differentiated Serv=
ices Codepoint: Default (0)
        .... .... ..00 .... .... .... .... .... =3D Explicit Congestion=
 Notification: Not ECN-Capable Transport (0)
    .... .... .... 0000 0000 0000 0000 0000 =3D Flowlabel: 0x00000000
    Payload length: 64
    Next header: ICMPv6 (58)
    Hop limit: 255
    Source: fe80::a5a6:793:6bfe:ea1c
    Destination: fe80::8019:47ef:17a1:8c38
    [Source GeoIP: Unknown]
    [Destination GeoIP: Unknown]
Internet Control Message Protocol v6
    Type: Router Advertisement (134)
    Code: 0
    Checksum: 0x96fa [correct]
    Cur hop limit: 255
    Flags: 0x40
        0... .... =3D Managed address configuration: Not set
        .1.. .... =3D Other configuration: Set
        ..0. .... =3D Home Agent: Not set
        ...0 0... =3D Prf (Default Router Preference): Medium (0)
        .... .0.. =3D Proxy: Not set
        .... ..0. =3D Reserved: 0
    Router lifetime (s): 65535
    Reachable time (ms): 0
    Retrans timer (ms): 0
    ICMPv6 Option (Source link-layer address : 02:50:f3:00:01:00)
        Type: Source link-layer address (1)
        Length: 1 (8 bytes)
        Link-layer address: 02:50:f3:00:01:00
    ICMPv6 Option (MTU : 1500)
        Type: MTU (5)
        Length: 1 (8 bytes)
        Reserved
        MTU: 1500
    ICMPv6 Option (Prefix information : 2a02:2121:81:e578::/64)
        Type: Prefix information (3)
        Length: 4 (32 bytes)
        Prefix Length: 64
        Flag: 0xc0
            1... .... =3D On-link flag(L): Set
            .1.. .... =3D Autonomous address-configuration flag(A): Set
            ..0. .... =3D Router address flag(R): Not set
            ...0 0000 =3D Reserved: 0
        Valid Lifetime: 4294967295 (Infinity)
        Preferred Lifetime: 4294967295 (Infinity)
        Reserved
        Prefix: 2a02:2121:81:e578::


nemi:/tmp# ifconfig wwan0
wwan0     Link encap:UNSPEC  HWaddr 00-00-00-00-00-00-00-00-00-00-00-00=
-00-00-00-00 =20
          inet addr:10.135.186.66  P-t-P:10.135.186.66  Mask:255.255.25=
5.252
          inet6 addr: 2a02:2121:81:e578:bce:7da1:24a5:af48/64 Scope:Glo=
bal
          inet6 addr: fe80::8019:47ef:17a1:8c38/64 Scope:Link
          UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1500  Metric:1
          RX packets:3 errors:0 dropped:0 overruns:0 frame:0
          TX packets:3 errors:0 dropped:0 overruns:0 carrier:0
          collisions:0 txqueuelen:1000=20
          RX bytes:716 (716.0 B)  TX bytes:704 (704.0 B)



(the other end is an LTE modem here)


Bj=C3=B8rn
