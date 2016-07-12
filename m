From: <Mario_Limonciello@Dell.com>
Subject: RE: [PATCH v6 RESEND] r8152: Add support for setting pass through MAC
 address on RTL8153-AD
Date: Tue, 12 Jul 2016 15:04:12 +0000
Message-ID: <5a304b784fe747aea4de6b69fb12a767@ausx13mpc124.AMER.DELL.COM>
References: <1468285084-26557-1-git-send-email-mario_limonciello@dell.com>
	<20160711.194246.742914205682079488.davem@davemloft.net>
 <20160712090248.7b5633e5@sauron>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-kernel@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-usb@vger.kernel.org>, <anthony.wong@canonical.com>
To: <michal.pecio@gmail.com>, <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160712090248.7b5633e5@sauron>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> -----Original Message-----
> From: Micha=B3 Pecio [mailto:michal.pecio@gmail.com]
> Sent: Tuesday, July 12, 2016 2:03 AM
> To: David Miller <davem@davemloft.net>
> Cc: Limonciello, Mario <Mario_Limonciello@Dell.com>; linux-
> kernel@vger.kernel.org; netdev@vger.kernel.org; linux-
> usb@vger.kernel.org; anthony.wong@canonical.com
> Subject: Re: [PATCH v6 RESEND] r8152: Add support for setting pass th=
rough
> MAC address on RTL8153-AD
>=20
> > From: Mario Limonciello <mario_limonciello@dell.com>
> > Date: Mon, 11 Jul 2016 19:58:04 -0500
> >
> > > The RTL8153-AD supports a persistent system specific MAC address.
> > > This means a device plugged into two different systems with host
> > > side support will show different (but persistent) MAC addresses.
> > >
> > > This information for the system's persistent MAC address is burne=
d
> > > in when the system HW is built and available under \_SB.AMAC in t=
he
> > > DSDT at runtime.
> > >
> > > This technology is currently implemented in the Dell TB15 and WD1=
5
> > > Type-C docks.  More information is available here:
> > > http://www.dell.com/support/article/us/en/04/SLN301147
> > >
> > > Signed-off-by: Mario Limonciello <mario_limonciello@dell.com>
> >
> > Applied.
>=20
> Hi,
>=20
> Isn't it possible that the same ACPI name could be used for other
> vendor-specific extensions on other laptops and that r8152 will now
> wreak havoc there?
>=20
> Regards,
> MP

This has been discussed a bit previously in earlier submissions.

In short, this is an extreme corner case.  Some changes were made=20
to diminish potential impact. The ACPI code is resolved only when=20
the specific variant of RTL8135 (-AD) has a bit set on the efuse.

The patch also explicitly checks the return type and contents of the
ACPI object and won't proceed if it's invalid.

The Type-C devices that provide this are currently only sold by Dell. =20
This of course may change one day if other OEM's add this
feature, but it just shows that device scope is limited.

=46or now the way this is implemented if Realtek does choose to=20
work with another OEM on this feature, there should be no
kernel code change necessary for interoperability of peripherals
on other OEM machines.

So in order to hit this hypothetical corner case today you would=20
need to be using a real world type-C device something such as a=20
Dell WD15 on another OEM's machine that has type-C and the exact
same ACPI object name that does $BADSTUFF other than return a
buffer.

If that situation arises please alert me and I'll send a follow up
patch that whitelists this to match DMI vendor of only Dell=20
systems.
