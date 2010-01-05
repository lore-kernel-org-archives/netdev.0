From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Tue, 05 Jan 2010 03:31:53 -0800
Message-ID: <1262691113.16627.361.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	 <1261604906.609.106.camel@localhost.localdomain>
	 <878wcdx6tt.fsf@nemi.mork.no>
	 <1262639441.16627.322.camel@localhost.localdomain>
	 <87iqbhuhre.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:42825 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754126Ab0AELdA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Jan 2010 06:33:00 -0500
In-Reply-To: <87iqbhuhre.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

> >> >> This patch adds the Sony Ericsson J105i (Naite)
> >> >> mobile phone to the cdc_ether device whitelist,
> >> >> enabling access to the modem.
> >> >> 
> >> >> I would think more SE models of this generation
> >> >> (2009Q3) with builtin HSDPA modules also needs
> >> >> to be added to this list.
> >> >
> >> > I do prefer if we NOT use the mbm_info details for this since they are
> >> > clearly for mobile broadband cards with FLAG_WWAN.
> >> 
> >> Assuming that these devices can be configured just like the WWAN cards
> >> by sending commands to the associated ACM* or WDM* interfaces, why would
> >> you treat them differently?  Because they've got a keyboard and a
> >> display?
> >
> > these are not like MBM devices WWAN cards. The MBM cards require to
> > setup the PDP context before the card will become ready. With an actual
> > phone you are already set.
> 
> You are?  AFAIK, the PDP context *may* be configured using the phone UI
> but it still needs to be setup.  And there are good reasons why you'd
> like to configure/setup/verify the PDP context from the PC even if one
> is setup using the phone UI. You will at least need to verify that a PDP
> context actually *is* setup.  And you might want to use a different APN
> than the one used when surfing from the phone.  You might even want to
> choose different APNs depending on context (for VPN access, e.g)
> 
> > So these are Ethernet devices and not WWAN cards.
> 
> Well, I argued that the WWAN card were Ethernet devices.  I realise that
> they've been defined otherwise now.  What I'm trying to understand are
> the finer details of this definition.  Exactly what defines a WWAN card?
> 
> >> > Since this is a phone where the setup of the connection is done via the
> >> > phone. And you just treat this as an Ethernet device and run DHCP, then
> >> > please create a se_info or similar with FLAG_ETHER.
> >> 
> >> Why would anyone want to setup the connection via the phone?  That seems
> >> unnecessary cumbersome. I'd prefer such devices to be auto-configured
> >> just like any other WWAN device.
> >
> > Are they WWAN devices? What these do is basically tethering via an
> > Ethernet like device. It does not require a telephony stack to drive
> > this hardware.
> 
> Do they connect automatically, or do you need to initiate the connection
> somehow?
> 
> > We require a proper DEVTYPE classification and these don't fall into the
> > category of WWAN devices. They can be treated like every other Ethernet
> > card and should be classified like this. We have FLAG_ETHER for this, so
> > please use that one.
> 
> I believe the WWAN cards also can be treated like every other USB
> Ethernet device, as far as the kernel is concerned.  Any differences are
> easily resolved by userspace applications. 

and this is where you are totally wrong. It is not easy for userspace to
identify the type of an interface and resolve things.

Take WiFi for example. We need to actually connect to a network before
these are useful. Same applies for 3G cards (aka WWAN) devices. You have
to register with the network, attach to GPRS etc. before any of this
becomes really useful. If the the USB network interface does automatic
connect and does tethering then it is not a WWAN device. Then it is an
Ethernet device.

And that you can use your phone via a TTY and configure a second PDP
context and then run PPP has nothing to do with its network device.

> So I'm still trying to figure out what makes a WWAN device special wrt
> the kernel.  Thanks for explaining.

It has nothing to do with the kernel. It classifies the network device
type for userspace. Like you classify /dev/sda as "disk" and /dev/sda1
as "partition".

So please modify your patch as outlined in my first response. It should
take you only like 5 minutes to do so. Then your phone will show up and
gets a proper classification.

Regards

Marcel


