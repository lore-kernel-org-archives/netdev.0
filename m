From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn@mork.no>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Tue, 05 Jan 2010 13:46:58 +0100
Message-ID: <87eim4vhvh.fsf@nemi.mork.no>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	<1261604906.609.106.camel@localhost.localdomain>
	<878wcdx6tt.fsf@nemi.mork.no>
	<1262639441.16627.322.camel@localhost.localdomain>
	<87iqbhuhre.fsf@nemi.mork.no>
	<1262691113.16627.361.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Marcel Holtmann <marcel@holtmann.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from canardo.mork.no ([148.122.252.1]:46622 "EHLO canardo.mork.no"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751396Ab0AEMrK convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 07:47:10 -0500
In-Reply-To: <1262691113.16627.361.camel@localhost.localdomain> (Marcel
	Holtmann's message of "Tue, 05 Jan 2010 03:31:53 -0800")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Marcel Holtmann <marcel@holtmann.org> writes:

>> I believe the WWAN cards also can be treated like every other USB
>> Ethernet device, as far as the kernel is concerned.  Any differences=
 are
>> easily resolved by userspace applications.=20
>
> and this is where you are totally wrong. It is not easy for userspace=
 to
> identify the type of an interface and resolve things.

No?  Well, I probably have a too limited view of this, but I found it
easy enough to create a pre-up/post-down script which checked whether
the network interface being brought up/down belongs to a supported WWAN
card and then do the necessary magic on one of the related cdc-wdm
channels. This was implemented by poking around in the sysfs.  I fail t=
o
see why one needs a special network device name to do that.

But it would have been useful to have the CDC MDLM header exported
somewhere in sysfs.  That's more of a generic usb/cdc thing though, I
guess.=20

> Take WiFi for example. We need to actually connect to a network befor=
e
> these are useful. Same applies for 3G cards (aka WWAN) devices. You h=
ave
> to register with the network, attach to GPRS etc. before any of this
> becomes really useful. If the the USB network interface does automati=
c
> connect and does tethering then it is not a WWAN device. Then it is a=
n
> Ethernet device.

I can live with that defintion of the difference between a WWAN/3G
device (wwan%d) and a USB Ethernet device (usb%d).

But I still don't see why this doesn't make a phone (supporting the sam=
e
commands as a 3G card) a WWAN device.  A phone can't do an automatic
connection any more than a WWAN card can.  Both *must* be configured
with at least one PDP context, register with the network, attach to GPR=
S
etc.

Yes, some phones can be configured to auto-connect using it's own
UI. But there's really nothing preventing anyone from implementing the
same feature for a WWAN card.  What would that make that card then?

> And that you can use your phone via a TTY and configure a second PDP
> context and then run PPP has nothing to do with its network device.

I was talking about the network device. =20

My experience with these devices is limited to the Ericsson F3507g, but
I assume that many of them will behave identically.  It allows you to
define multiple PDP contexts and select which one you connect with,
either you use PPP or the network device.  The list of defined contexts
are in fact shared.

>> So I'm still trying to figure out what makes a WWAN device special w=
rt
>> the kernel.  Thanks for explaining.
>
> It has nothing to do with the kernel. It classifies the network devic=
e
> type for userspace. Like you classify /dev/sda as "disk" and /dev/sda=
1
> as "partition".
>
> So please modify your patch as outlined in my first response. It shou=
ld
> take you only like 5 minutes to do so. Then your phone will show up a=
nd
> gets a proper classification.

Sorry for the confusion, but the patch was not mine.  I just stumbled
across the discussion and first wondered why the heck the mbm_info stuf=
f
was added (hadn't noticed before) and then why the heck this device
should be treated differenctly if it shows up as a similar one.



Bj=C3=B8rn
