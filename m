From: Dan Williams <dcbw@redhat.com>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Wed, 06 Jan 2010 22:38:41 -0800
Message-ID: <1262846321.3608.76.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	 <1261604906.609.106.camel@localhost.localdomain>
	 <878wcdx6tt.fsf@nemi.mork.no>
	 <1262639441.16627.322.camel@localhost.localdomain>
	 <87iqbhuhre.fsf@nemi.mork.no>
	 <1262691113.16627.361.camel@localhost.localdomain>
	 <87eim4vhvh.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Marcel Holtmann <marcel@holtmann.org>, netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:34269 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751006Ab0AGGjB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Jan 2010 01:39:01 -0500
In-Reply-To: <87eim4vhvh.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-01-05 at 13:46 +0100, Bj=C3=B8rn Mork wrote:
> Marcel Holtmann <marcel@holtmann.org> writes:
>=20
> >> I believe the WWAN cards also can be treated like every other USB
> >> Ethernet device, as far as the kernel is concerned.  Any differenc=
es are
> >> easily resolved by userspace applications.=20
> >
> > and this is where you are totally wrong. It is not easy for userspa=
ce to
> > identify the type of an interface and resolve things.
>=20
> No?  Well, I probably have a too limited view of this, but I found it
> easy enough to create a pre-up/post-down script which checked whether
> the network interface being brought up/down belongs to a supported WW=
AN
> card and then do the necessary magic on one of the related cdc-wdm
> channels. This was implemented by poking around in the sysfs.  I fail=
 to
> see why one needs a special network device name to do that.
>=20
> But it would have been useful to have the CDC MDLM header exported
> somewhere in sysfs.  That's more of a generic usb/cdc thing though, I
> guess.=20
>=20
> > Take WiFi for example. We need to actually connect to a network bef=
ore
> > these are useful. Same applies for 3G cards (aka WWAN) devices. You=
 have
> > to register with the network, attach to GPRS etc. before any of thi=
s
> > becomes really useful. If the the USB network interface does automa=
tic
> > connect and does tethering then it is not a WWAN device. Then it is=
 an
> > Ethernet device.
>=20
> I can live with that defintion of the difference between a WWAN/3G
> device (wwan%d) and a USB Ethernet device (usb%d).
>=20
> But I still don't see why this doesn't make a phone (supporting the s=
ame
> commands as a 3G card) a WWAN device.  A phone can't do an automatic
> connection any more than a WWAN card can.  Both *must* be configured
> with at least one PDP context, register with the network, attach to G=
PRS
> etc.
>=20
> Yes, some phones can be configured to auto-connect using it's own
> UI. But there's really nothing preventing anyone from implementing th=
e
> same feature for a WWAN card.  What would that make that card then?
>=20
> > And that you can use your phone via a TTY and configure a second PD=
P
> > context and then run PPP has nothing to do with its network device.
>=20
> I was talking about the network device. =20
>=20
> My experience with these devices is limited to the Ericsson F3507g, b=
ut
> I assume that many of them will behave identically.  It allows you to

Haha.  No.  Never assume that two WWAN devices (or even two phones) wil=
l
behave identically.  It's almost never the case.

> define multiple PDP contexts and select which one you connect with,
> either you use PPP or the network device.  The list of defined contex=
ts
> are in fact shared.

Here's the difference:

=463507g: requires AT command setup before cdc-ether port is usable
SE j105i: does not require AT command setup before port is usable

Same on my TM-506; you can simply run DHCP on the 'usb0' port and it
works, because the phone is pretending to be a usb-ethernet device and
transparently bridge between the ethernet and the cellular network.
That's simply not the case with the F3507g or any other WWAN card.

Phones are fundamentally different than WWAN cards and shouldn't be
treated like one, at least at this time.

Dan

> >> So I'm still trying to figure out what makes a WWAN device special=
 wrt
> >> the kernel.  Thanks for explaining.
> >
> > It has nothing to do with the kernel. It classifies the network dev=
ice
> > type for userspace. Like you classify /dev/sda as "disk" and /dev/s=
da1
> > as "partition".
> >
> > So please modify your patch as outlined in my first response. It sh=
ould
> > take you only like 5 minutes to do so. Then your phone will show up=
 and
> > gets a proper classification.
>=20
> Sorry for the confusion, but the patch was not mine.  I just stumbled
> across the discussion and first wondered why the heck the mbm_info st=
uff
> was added (hadn't noticed before) and then why the heck this device
> should be treated differenctly if it shows up as a similar one.
>=20
>=20
>=20
> Bj=C3=B8rn
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

