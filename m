From: Christian Hesse <mail@eworm.de>
Subject: Re: sky2, vlan and nat/masquerading
Date: Tue, 15 Mar 2011 08:53:26 +0100
Message-ID: <20110315085326.1a1019aa@leda.vpn.lugor.de>
References: <20110309181522.61ca1cc7@leda.vpn.lugor.de>
	<AANLkTi=AJJA0d0=CFuS66=+O6b80Ejj0w3NfKQ+OWzsK@mail.gmail.com>
	<20110314111105.5a62e092@leda.vpn.lugor.de>
	<AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="MP_/Brthehww4jn9UnaNdKKuvPB"
Cc: netdev@vger.kernel.org
To: Jesse Gross <jesse@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.mylinuxtime.de ([80.190.48.209]:60641 "EHLO
	mx.mylinuxtime.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753944Ab1COHxd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Mar 2011 03:53:33 -0400
In-Reply-To: <AANLkTikXBz6ZpuSgqaAV-=Jr3qtDQ3T_We42R65Sd20O@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--MP_/Brthehww4jn9UnaNdKKuvPB
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline

On Mon, 14 Mar 2011 18:55:17 -0700 Jesse Gross <jesse@nicira.com> wrote:
> On Mon, Mar 14, 2011 at 3:11 AM, Christian Hesse <mail@eworm.de> wrote:
> > Ok, let me explain step by step:
>=20
> Thank you, this helps a lot in understanding your setup.
>=20
> >
> > * Host sends icmp echo request (172.16.0.21 -> 192.168.100.3) to router
> > =A0172.16.0.1, the packet is untagged.
> > * Switch receives the packet on native interface with vid 2, tags it and
> > sends it to the trunk)
> > * Netbook receives the packet from trunk, untags it an queues it to vlan
> > =A0interface 2.
> > * Netbook nats the packet (192.168.x.140 > 192.168.100.3), tags it with
> > vlan 2 and sends it to the trunk.
>=20
> For clarity, I'm assuming that this is supposed to be vlan 1?

Sorry, little typo. Yes, you are right.

> > * Switch receives the packet from trunk, untags it and sends it to nati=
ve
> > =A0interface with vlan 1.
> > * The packet and its answer (192.168.100.3 -> 192.168.x.140) make their
> > way through the network.
> > * Switch receives the icmp echo reply on native interface with vlan 1,
> > tags it and sends it to the trunk
> > * Netbook receives the packet from trunk, untags it an queues it to vlan
> > =A0interface 1.
> > * Netbooks restores the original addresses from nat (192.168.100.3 ->
> > =A0172.16.0.21), _tags_it_with_vlan_0_, tags it with vlan 2 and sends i=
t to
> > the trunk
>=20
> Can you capture a packet trace on the netbook's Ethernet interface to
> see what it thinks it is sending?

Ok, I have two traces for you: from the vlan interface and from the native
interface. First ping to 172.16.0.65 is ok, second one to 192.168.100.3 fai=
ls.

Please don't be confused, vlan 1 is vlan 3 this time and addresses
changed a little bit. ;)
--=20
Schoene Gruesse
Chris

--MP_/Brthehww4jn9UnaNdKKuvPB
Content-Type: application/octet-stream; name=tcpdump-eth.2.log
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=tcpdump-eth.2.log

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAnxV/TW+nCABiAAAAYgAAAAAkVNg6YQAmLfegqQgARQAA
VAAAQABAAeH9rBAASqwQAEEIAIOeNvwAAZ8Vf00AAAAAUy4NAAAAAAAQERITFBUWFxgZGhscHR4f
ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3nxV/TUyoCABiAAAAYgAAAAAmLfegqQAkVNg6YQgARQAA
VI9XAABAAZKmrBAAQawQAEoAAIueNvwAAZ8Vf00AAAAAUy4NAAAAAAAQERITFBUWFxgZGhscHR4f
ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3nxV/TdOwCABiAAAAYgAAAAAkVNg6YQAmLfegqQgARQAA
VAAAQABAAWmjrBAASsCoZAMIAMSTNv0AAZ8Vf00AAAAAEjgNAAAAAAAQERITFBUWFxgZGhscHR4f
ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3nxV/Tcq1CABiAAAAYgAAAAAmLfegqQAkVNg6YQgARQAA
VMNbAAA9AelHwKhkA6wQAEoAAMyTNv0AAZ8Vf00AAAAAEjgNAAAAAAAQERITFBUWFxgZGhscHR4f
ICEiIyQlJicoKSorLC0uLzAxMjM0NTY3

--MP_/Brthehww4jn9UnaNdKKuvPB
Content-Type: application/octet-stream; name=tcpdump-eth.log
Content-Transfer-Encoding: base64
Content-Disposition: attachment; filename=tcpdump-eth.log

1MOyoQIABAAAAAAAAAAAAP//AAABAAAAnxV/TW+nCABmAAAAZgAAAAAkVNg6YQAmLfegqYEAAAII
AEUAAFQAAEAAQAHh/awQAEqsEABBCACDnjb8AAGfFX9NAAAAAFMuDQAAAAAAEBESExQVFhcYGRob
HB0eHyAhIiMkJSYnKCkqKywtLi8wMTIzNDU2N58Vf01pqAgAZgAAAGYAAAAAJi33oKkAJFTYOmGB
AAACCABFAABUj1cAAEABkqasEABBrBAASgAAi542/AABnxV/TQAAAABTLg0AAAAAABAREhMUFRYX
GBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1NjefFX9N07AIAGYAAABmAAAAACRU2DphACYt
96CpgQAAAggARQAAVAAAQABAAWmjrBAASsCoZAMIAMSTNv0AAZ8Vf00AAAAAEjgNAAAAAAAQERIT
FBUWFxgZGhscHR4fICEiIyQlJicoKSorLC0uLzAxMjM0NTY3nxV/TUuxCABqAAAAagAAAAAADAes
SgAkVNg6YYEAAAOBAAAACABFAABUAABAAD8BwngKE0pywKhkAwgAxJM2/QABnxV/TQAAAAASOA0A
AAAAABAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1NjefFX9NRLUIAGYAAABm
AAAAACRU2DphABkvhkO/gQAAAwgARQAAVMNbAAA+AUAdwKhkAwoTSnIAAMyTNv0AAZ8Vf00AAAAA
EjgNAAAAAAAQERITFBUWFxgZGhscHR4fICEiIyQlJicoKSorLC0uLzAxMjM0NTY3nxV/TfK1CABq
AAAAagAAAAAmLfegqQAkVNg6YYEAAAKBAAAACABFAABUw1sAAD0B6UfAqGQDrBAASgAAzJM2/QAB
nxV/TQAAAAASOA0AAAAAABAREhMUFRYXGBkaGxwdHh8gISIjJCUmJygpKissLS4vMDEyMzQ1Njc=

--MP_/Brthehww4jn9UnaNdKKuvPB--
