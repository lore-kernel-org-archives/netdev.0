From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] IPv6: don't forward unspecified frames
Date: Tue, 23 Feb 2010 08:46:40 -0800
Message-ID: <20100223084640.326273aa@nehalam>
References: <20100222173153.79190176@nehalam>
	<4B836385.8090509@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:58631 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752373Ab0BWQqw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 11:46:52 -0500
In-Reply-To: <4B836385.8090509@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Feb 2010 13:11:33 +0800
Shan Wei <shanwei@cn.fujitsu.com> wrote:

> Stephen Hemminger wrote, at 02/23/2010 09:31 AM:
> > This showed up during UNH IPv6 conformance tests. It appears kernel
> > incorrectly forwards packets with unspecified source address.
>=20
> Which case? Is it about spec.p2#18 of IPv6 Ready Logo Phase 2?
> I don't see the phenomenon from spec.p2#18 case.

The kernel is 2.6.31 and it has that code section in ip6_forward.
I am inprocess of trying to reproduce the result.

The test case in question is V6LC.1.1.10C


 IP Forwarding =E2=80=93 Source and Destination Address =E2=80=93 Inter=
mediate Node (Routers Only)
 Purpose: Verify that a node properly forwards the ICMPv6 Echo Requests=
=2E
 Comments on Test Procedure
A. Request sent to Global Unicast address: TN2 transmits an ICMPv6 Echo=
 Request to TN1=E2=80=99s Global unicast address with a first hop throu=
gh the RUT. The source address is TN2=E2=80=99s Global address.
B. Request sent to Global Unicast address (prefix end in zero-valued fi=
elds): TN2 transmits an ICMPv6 Echo Request to TN1=E2=80=99s Global uni=
cast address (prefix 8000:0000::/64) with a first hop through the RUT. =
The source address is TN2=E2=80=99s Global address.
>>> C. Request sent from unspecified address: TN2 transmits an ICMPv6 E=
cho Request to TN1 with a first hop through the RUT. The source address=
 is the unspecified address (0:0:0:0:0:0:0:0).
D. Request sent to Lookback address: TN2 transmits an ICMPv6 Echo Reque=
st to the Lookback address (0:0:0:0:0:0:0:1) with a first hop through t=
he RUT. The source address is TN2=E2=80=99s Global address.
E. Request sent from Link Local address: TN2 transmits an ICMPv6 Echo R=
equest to TN1 with a first hop through the RUT. The source address is T=
N2=E2=80=99s Link Local address.
=46. Request sent to Link Local address: TN2 transmits an ICMPv6 Echo R=
equest to TN1=E2=80=99s Link Local address with a first hop through the=
 RUT. The source address is TN2=E2=80=99s Global address.
G. Request sent to Site-Local address: TN2 transmits an ICMPv6 Echo Req=
uest to TN1=E2=80=99s Site-local address with a first hop through the R=
UT. The source address is TN2=E2=80=99s Global address.
H. Request sent to Global Scope multicast address: Configure multicast =
routing on the RUT. TN1 is a Lis-tener for the multicast group FF1E::1:=
2. TN2 transmits an ICMPv6 Echo Request to TN1=E2=80=99s Global Scope m=
ulticast address (FF1E::1:2) with a first hop through the RUT. The sour=
ce address is TN2=E2=80=99s Global ad-dress.
I. Request sent to Link-local Scope multicast address: Configure multic=
ast routing on the RUT. TN1 is a Lis-tener for the multicast group FF12=
::1:2. TN2 transmits an ICMPv6 Echo Request to TN1=E2=80=99s Link-Local=
 Scope multicast address (FF12::1:2) with a first hop through the RUT. =
The source address is TN2=E2=80=99s Global address.
J. Request sent to Multicast address (Reserved Value =3D 0):Configure m=
ulticast routing on the RUT. TN1 is a Listener for the multicast group =
=46F10::1:2. TN2 transmits an ICMPv6 Echo Request to multicast address =
with a reserved field set to zero (FF10::1:2) with a first hop through =
the RUT. The source address is TN2=E2=80=99s Global address.
K. Request sent to Multicast address (Reserved Value =3D F): Configure =
multicast routing on the RUT. TN1 is a Listener for the multicast group=
 FF1F::1:2. 29. TN2 transmits an ICMPv6 Echo Request to TN1 multicast a=
ddress with a reserved field set to zero (FF1F::1:2) with a first hop t=
hrough the RUT. The source address is TN2=E2=80=99s Global address.

 Comments on Test Results
A. The RUT must forward the Echo Request from TN2 to TN1 with a first h=
op through the TR1.
B. The RUT must forward the Echo Request from TN2 to TN1 with a first h=
op through the TR1.
>>>C. The RUT forwarded the Echo Request from TN2.
According to RFC 4291 Section 2.5.2: =E2=80=9CAn IPv6 packet with a sou=
rce address of unspecified must never be forwarded by an IPv6 router.=E2=
=80=9D
Therefore the RUT should not have forwarded the Echo Request from TN2.
D. The RUT must not forward the Echo Request from TN2.
E. The RUT must not forward the Echo Request from TN2.
=46. The RUT must not forward the Echo Request from TN2.
G. The RUT must forward the Echo Request from TN2 to TR1.
H. The RUT must forward the Echo Request from TN2 to TN1 with a first h=
op through TR1.
I. The RUT must not forward the Echo Request from TN2.
J. The RUT must not forward the Echo Request from TN2.
K. The RUT must forward the Echo Request from TN2 to TN1 with a first h=
op through the RUT.
