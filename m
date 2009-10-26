From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: VLAN and ARP failure on tg3 drivers
Date: Mon, 26 Oct 2009 09:54:31 +0100
Message-ID: <4AE563C7.5070702@gmail.com>
References: <477963.52849.qm@web32605.mail.mud.yahoo.com> <m34opmr2fz.fsf@ursa.amorsen.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Gertjan Hofman <gertjan_hofman@yahoo.com>,
	Matt Carlson <mcarlson@broadcom.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Benny Amorsen <benny+usenet@amorsen.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48850 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755256AbZJZIye (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Oct 2009 04:54:34 -0400
In-Reply-To: <m34opmr2fz.fsf@ursa.amorsen.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Benny Amorsen a =C3=A9crit :
> Gertjan Hofman <gertjan_hofman@yahoo.com> writes:
>=20
>> Dear Matt, Eric, Benny,
>>
>> Sorry about the slow response to your fast replies. I think Benny is
>> correct, the 'problem' lies in the fact that we were using a VLAN ID
>> of 0, without knowing its special significance. User error.
>>
>> I tested it with other VLAN id's (>0) and it appears to work fine. W=
e
>> are not entirely sure we understand  why it used to work with VLAN I=
D
>> 0 on the Broadcom chips and still does with a number of different
>> cards (with >2.6.27 kernels).  What is the 'correct' behaviour for
>> this incorrect usage ?
>=20
> VLAN 0 isn't incorrect, it's just surprising. When you send a packet
> tagged with VLAN 0, it means that the packet should be interpreted as
> being the same VLAN as a completely untagged packet.
>=20
> So in theory, if both ends are using VLAN 0 and you aren't using eth0
> for anything, traffic should flow, at least if both ends are on the s=
ame
> kernel version. Feel free to debug why that isn't the case for you, o=
f
> course...
>=20

VLAN id 0 is not usable on current kernel because we use 16 bits in skb=
 to
 store vlan_tci, and vlan_tci =3D 0 means there is no VLAN tagging.


We could use high order bit (0x8000) to tell if vlan tagging is set or =
not.
