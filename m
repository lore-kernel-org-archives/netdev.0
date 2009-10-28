From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] vlan: allow VLAN ID 0 to be used
Date: Wed, 28 Oct 2009 17:13:26 +0100
Message-ID: <4AE86DA6.40408@trash.net>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com>	<m34opmr2fz.fsf@ursa.amorsen.dk> <4AE563C7.5070702@gmail.com>	<4AE5CAC6.4000604@gmail.com> <m3aazdb1ue.fsf@ursa.amorsen.dk> <4AE6C54B.7080805@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Benny Amorsen <benny+usenet@amorsen.dk>,
	Gertjan Hofman <gertjan_hofman@yahoo.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:61311 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752873AbZJ1QpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 12:45:06 -0400
In-Reply-To: <4AE6C54B.7080805@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Benny Amorsen a =E9crit :
>> Eric Dumazet <eric.dumazet@gmail.com> writes:
>>
>>> Here is the patch I cooked that permitted VLAN 0 to be used with tg=
3
>>> (and other HW accelerated vlan nics I suppose)
>>>
>>> [PATCH] vlan: allow VLAN ID 0 to be used
>>>
>>> We currently use a 16 bit field (vlan_tci) to store VLAN ID on a sk=
b.
>>>
>>> 0 value is used a special value, meaning VLAN ID not set.
>>> This forbids use of VLAN ID 0
>> Are you sure you actually want to do this?
>>
>> VLAN 0 IS special. Frames received on VLAN 0 should be treated just =
as
>> if they had no VLAN tag at all, except that they have an 802.1p valu=
e.
>>
>> Sending frames with VLAN 0 should have something to do with whether
>> the sender wants to use 802.1p, which doesn't really have much to do
>> with VLAN's at all...
>>
>> It would be nice if the unsuspecting user was at least warned that t=
heir
>> use of VLAN 0 is non-standard and may cause surprising results like
>> leakage into the "native" VLAN. That could be done in /sbin/ip or
>> /sbin/vconfig, of course.
>>
>=20
> Quotting http://en.wikipedia.org/wiki/IEEE_802.1Q
>=20
> VLAN Identifier (VID): a 12-bit field specifying the VLAN to which th=
e frame belongs.
>  A value of 0 means that the frame doesn't belong to any VLAN; in thi=
s case the 802.1Q
>  tag specifies only a priority and is referred to as a priority tag.
> A value of hex FFF is reserved for implementation use.
> All other values may be used as VLAN identifiers, allowing up to 4094=
 VLANs
>=20
>=20
> So we expect to generate a 802.1Q frame, even with a VID=3D0 field.
> Before patch, device sends a non 802.1Q frame, which is not what was =
wanted by user.
> (Maybe he wants to check its device/network is able to transport 1522=
 bytes frames, who knows...)
>=20
> To use non tagged frames, user selects eth0 device, and to send tagge=
d frames, he selects eth0.0

I agree. Quoting IEEE802.1Q:

0 The null VLAN ID. Indicates that the tag header contains only priorit=
y
  information; no VLAN identifier is present in the frame. ...

which implies that its valid to use 0 as tag in the header.

> Now, maybe eth0 and eth0.0 should share same IP addresses, because in=
coming frame
> with ID=3D0 tag should be received by eth0 device, but I am not sure =
standard requires this.

I don't think the standard makes any demands regarding this.

The current behaviour seems better to me since its symetrical
to the output path, where the VLAN device is necessary to be
able to specify a priority mapping.


