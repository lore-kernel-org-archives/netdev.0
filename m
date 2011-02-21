From: Brent Cook <bcook@breakingpoint.com>
Subject: Re: Off-by-one error in net/8021q/vlan.c
Date: Mon, 21 Feb 2011 13:26:00 -0600
Message-ID: <201102211326.00255.bcook@breakingpoint.com>
References: <4D5BADCF.5000804@ka9q.net> <1297874372.30541.29.camel@edumazet-laptop> <AANLkTimrQy6gU8d86m2jM4arMS0rOvEQmn2m-KTE4sx9@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, Phil Karn <karn@ka9q.net>,
	richard -rw- weinberger <richard.weinberger@gmail.com>,
	<kaber@trash.net>, <netdev@vger.kernel.org>
To: =?utf-8?q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.breakingpoint.com ([65.36.7.12]:40744 "EHLO
	EXCHANGE.securitytestsystems.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752986Ab1BUTb0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Feb 2011 14:31:26 -0500
In-Reply-To: <AANLkTimrQy6gU8d86m2jM4arMS0rOvEQmn2m-KTE4sx9@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wednesday 16 February 2011 12:41:34 Micha=C5=82 Miros=C5=82aw wrote:
> 2011/2/16 Eric Dumazet <eric.dumazet@gmail.com>:
> > Le mercredi 16 f=C3=A9vrier 2011 =C3=A0 08:28 -0800, Phil Karn a =C3=
=A9crit :
> >> On 2/16/11 8:10 AM, richard -rw- weinberger wrote:
> >> > On Wed, Feb 16, 2011 at 4:58 PM, Phil Karn <karn@ka9q.net> wrote=
:
> >> >> On 2/16/11 4:51 AM, richard -rw- weinberger wrote:
> >> >>> On Wed, Feb 16, 2011 at 11:58 AM, Phil Karn <karn@ka9q.net> wr=
ote:
> >> >>>> The range check on vlan_id in register_vlan_device is off by =
one, and it
> >> >>>> prevents the creation of a vlan interface for vlan ID 4095. (=
OSX allows
> >> >>>> this, I checked.)
> >> >>>
> >> >>> Then OSX should fix their code. 4095 is reserved.
> >> >> If it's reserved, then it's up to the user to reserve it.
> >> > No.
> >> > See:
> >> > http://standards.ieee.org/getieee802/download/802.1Q-2005.pdf
> >> Well, then I guess we all know better than the user. That's the Wi=
ndows
> >> Way...no, wait, I thought this is Linux.
> >>
> >> The fact is that I did encounter a misconfigured switch using vlan=
 4095,
> >> and because of this off-by-one error I was unable to talk to it an=
d fix it.
> >>
> >> I was hoping I wouldn't have to patch every new kernel I install.
> > You can use an OSX gateway ;)
> >
> > If we allow ID 4095, then some users will complain we violate rules=
=2E
> >
> > Really you cannot push this patch in official kernel only to ease y=
our
> > life ;)
>=20
> The idea is that you don't have to use ID 4095 and if you don't -
> nothing's broken by just allowing it. The same goes with ID 0 - it's
> defined to be 802.1p packet, but people do use it as normal VLAN
> (especially with hardware that can cope with only small number of
> VLANs at once).
>=20
> Allowing it but with a big fat warning in logs is even better: "You
> want your network broken? Sure, can do, but you have been warned."
>=20

On the other end of the spectrum, vconfig warns for vlan 1:

bcook@bcook-box:~$ sudo vconfig add eth0 1
Added VLAN with VID =3D=3D 1 to IF -:eth0:-
WARNING:  VLAN 1 does not work with many switches,
consider another number if you have problems.
bcook@bcook-box:~$ sudo vconfig add eth0 4095
ERROR: trying to add VLAN #4095 to IF -:eth0:-  error: Numerical result=
 out of range
