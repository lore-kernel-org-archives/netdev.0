From: Ben Hutchings <ben@decadent.org.uk>
Subject: Re: [PATCH net-next V4 00/12] net/mlx5: ConnectX-4 100G Ethernet
 driver
Date: Wed, 27 May 2015 20:57:37 +0100
Message-ID: <1432756657.6319.22.camel@decadent.org.uk>
References: <20150519.124128.353071028525864155.davem@davemloft.net>
	 <CAPcc5Ph+JOZO=bnh6f7DJ-B9=z1cCWy_HJdBx1-BG2_JKgTVtA@mail.gmail.com>
	 <CAJ3xEMiteyRsGuNQoQYiiZKeWkpjQE8WcJdQfWyxntJ9bjYXcw@mail.gmail.com>
	 <20150527.133620.1867770619067144773.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
	protocol="application/pgp-signature"; boundary="=-2g+46+MgXZQRWs45CjDO"
Cc: gerlitz.or@gmail.com, netdev@vger.kernel.org,
	ogerlitz@mellanox.com, talal@mellanox.com, achiad@mellanox.com,
	saeedm@mellanox.com, amirv@mellanox.com, edumazet@google.com,
	tom@herbertland.com, jiri@resnulli.us, bpoirier@suse.de,
	nhorman@tuxdriver.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from shadbolt.e.decadent.org.uk ([88.96.1.126]:43626 "EHLO
	shadbolt.e.decadent.org.uk" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750868AbbE0T57 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 15:57:59 -0400
In-Reply-To: <20150527.133620.1867770619067144773.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-2g+46+MgXZQRWs45CjDO
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Wed, 2015-05-27 at 13:36 -0400, David Miller wrote:
> From: Or Gerlitz <gerlitz.or@gmail.com>
> Date: Mon, 25 May 2015 22:07:23 +0300
>=20
> > On Wed, May 20, 2015 at 5:17 PM, Amir Vadai <amirv@mellanox.com> wrote:
> >> On Tue, May 19, 2015 at 7:41 PM, David Miller <davem@davemloft.net> wr=
ote:
> >>> From: Amir Vadai <amirv@mellanox.com>
> >>> Date: Tue, 19 May 2015 12:25:12 +0300
> >>>
> >>>> On Sun, May 17, 2015 at 8:05 PM, David Miller <davem@davemloft.net> =
wrote:
> >>>>> From: Amir Vadai <amirv@mellanox.com>
> >>>>> Date: Sun, 17 May 2015 16:02:11 +0300
> >>>>>
> >>>>>> We didn't get a response yet regarding your comment about the irq
> >>>>>> renaming [3].
> >>>>>
> >>>>> Well then, please hold off on resubmissions of this series until yo=
u
> >>>>> do get a response and that issue is firmly resolved.
> >>>> Hi,
> >>>>
> >>>> I don't mean to push you, I only want to understand what is expected
> >>>> from me and what are the next steps:
> >>>> How will the issue be resolved? Do you plan to answer my question [1=
]
> >>>> from last week, and just too busy right now or something like that?
> >>>
> >>> I have not seen any response to me explaining why it's ok to change
> >>> the IRQ name strings in the context where this will occur.
> >>>
> >>> Once you explain that, we can make forward progress, but only at that
> >>> point.
> >>
> >> Hi Dave,
> >>
> >> Just to put us back on the same page, repeating a bit the previous cha=
pters..
> >>
> >> You wrote [1] that if we change these names after the request_irq() ca=
ll(s), the
> >> new name string will not propagate to /proc/interrupts output.
> >>
> >> So, indeed, request_irq() is called when the driver is loaded (and we
> >> don't know yet if the port types are Infiniband or Ethernet). Only lat=
er
> >> on, we rename the name when the Ethernet interface is up and we know
> >> its name.
> >>
> >> Fact is that the new name does propagate to /proc/interrupts.
> >>
> >> Also, looking in the code, I don't see a reason why shouldn't it
> >> be properly updated. When calling request_irq(), the name argument
> >> is not copied, but irq_desc->action->name points to it. This same poin=
ter
> >> is being used by show_interrupts() when /proc/interrupts is shown.
>=20
> The problem is, applications might cache the name of the interrupt source
> from /proc/interrupts or elsewhere as soon as the device is instantiated.
>
> You cannot change it after you've published it there.

How would an application tell the difference between an IRQ handler
being renamed, or being unregistered and re-registered under a different
name?  I'm fairly sure it can't tell.

> Therefore, it is mandatory that the name string is at the time you call
> request_irq().

It certainly ought to be something non-null and a useful identifier for
the device.  But the convention of including the net device name means
that either the interrupt handler should be registered only when the
device is up, or it should be renamed when the device is.

There are certainly some network drivers that handle interrupts while
the device is down, e.g. because they have a PHC.  Should those
interrupt handlers be named after the PCI device instead?

Ben.

--=20
Ben Hutchings
Reality is just a crutch for people who can't handle science fiction.

--=-2g+46+MgXZQRWs45CjDO
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIVAwUAVWYhtee/yOyVhhEJAQoSUg/9HJ4bVlvuZ6qbfzo1fre2288Fru0r3xXj
s1pCZlc12gqSRBJXCR8h4L8BgJByFoVVhVlyKrVVICzhPUUtJ/OBotWD/+3zqfdH
UXcBtadxK0yLWJYQ4pm0NJLi15vsXukzB5BHlVL6t8H1BE3JbSquIRy6aE+bwzKi
tZElKgPuAitIxF5P9L7OLugmbEpI3PyJfVOw8b6J4UsMuhBmZqorf3KYAu6daK/7
J13TyzkF5McYQblJURmMMObZmKBjhc1HmC/uFnHFsI/elV351AhV802PTDfSCYGG
OvlTdharbIwHAm46F4NYR61IIuLFVMs/BzyVXmdP6JbB5p1KYmgkE4PmizK2C0eL
2beaWGmFWVmhx+uaN/Wv00fu5YTdGaFrDnle3X/3bfo0Eh6OxA48WPf3vAXO0yyn
AJIdi9q9HRCweUiBm/7ln5WL/qIQb5+GIeopvRJ/Lk2fCtH7izGwxGxFevhGlYxu
kPf6CxWi+I8Arf9KT1Bu4sH1OETTKWzwPzVtvEYsGR/JPP6xd0fOVMGy9rUzKd9G
NhOVEdfWxUwPWFPSE2KD5+O6jwgBvAjUBjD3PToUTDZzO+HvkhPlA3h5+KP1FbKN
XPNlqJtfI0tVs6SNydxTLjZAalu/2o7pddt12qkEbR6f06LDJXRKRj8bxN37LaF0
vgveasFKumE=
=H4vf
-----END PGP SIGNATURE-----

--=-2g+46+MgXZQRWs45CjDO--
