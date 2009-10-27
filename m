From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Tue, 27 Oct 2009 11:02:51 +0100
Message-ID: <4AE6C54B.7080805@gmail.com>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com>	<m34opmr2fz.fsf@ursa.amorsen.dk> <4AE563C7.5070702@gmail.com>	<4AE5CAC6.4000604@gmail.com> <m3aazdb1ue.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gertjan Hofman <gertjan_hofman@yahoo.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Patrick McHardy <kaber@trash.net>,
	"David S. Miller" <davem@davemloft.net>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:44430 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbZJ0KD2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 06:03:28 -0400
In-Reply-To: <m3aazdb1ue.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen a =E9crit :
> Eric Dumazet <eric.dumazet@gmail.com> writes:
>=20
>> Here is the patch I cooked that permitted VLAN 0 to be used with tg3
>> (and other HW accelerated vlan nics I suppose)
>>
>> [PATCH] vlan: allow VLAN ID 0 to be used
>>
>> We currently use a 16 bit field (vlan_tci) to store VLAN ID on a skb=
=2E
>>
>> 0 value is used a special value, meaning VLAN ID not set.
>> This forbids use of VLAN ID 0
>=20
> Are you sure you actually want to do this?
>=20
> VLAN 0 IS special. Frames received on VLAN 0 should be treated just a=
s
> if they had no VLAN tag at all, except that they have an 802.1p value=
=2E
>=20
> Sending frames with VLAN 0 should have something to do with whether
> the sender wants to use 802.1p, which doesn't really have much to do
> with VLAN's at all...
>=20
> It would be nice if the unsuspecting user was at least warned that th=
eir
> use of VLAN 0 is non-standard and may cause surprising results like
> leakage into the "native" VLAN. That could be done in /sbin/ip or
> /sbin/vconfig, of course.
>=20

Quotting http://en.wikipedia.org/wiki/IEEE_802.1Q

VLAN Identifier (VID): a 12-bit field specifying the VLAN to which the =
frame belongs.
 A value of 0 means that the frame doesn't belong to any VLAN; in this =
case the 802.1Q
 tag specifies only a priority and is referred to as a priority tag.
A value of hex FFF is reserved for implementation use.
All other values may be used as VLAN identifiers, allowing up to 4094 V=
LANs


So we expect to generate a 802.1Q frame, even with a VID=3D0 field.
Before patch, device sends a non 802.1Q frame, which is not what was wa=
nted by user.
(Maybe he wants to check its device/network is able to transport 1522 b=
ytes frames, who knows...)

To use non tagged frames, user selects eth0 device, and to send tagged =
frames, he selects eth0.0


Now, maybe eth0 and eth0.0 should share same IP addresses, because inco=
ming frame
with ID=3D0 tag should be received by eth0 device, but I am not sure st=
andard requires this.

