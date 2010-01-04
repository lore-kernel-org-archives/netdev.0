From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] net: cdc_ether.c: Add SE J105i to device whitelist
Date: Mon, 04 Jan 2010 13:10:41 -0800
Message-ID: <1262639441.16627.322.camel@localhost.localdomain>
References: <1261601807-8385-1-git-send-email-tloo@saltstorm.net>
	 <1261604906.609.106.camel@localhost.localdomain>
	 <878wcdx6tt.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Bj=F8rn?= Mork <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36409 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751883Ab0ADVLq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jan 2010 16:11:46 -0500
In-Reply-To: <878wcdx6tt.fsf@nemi.mork.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Bjorn,

> >> This patch adds the Sony Ericsson J105i (Naite)
> >> mobile phone to the cdc_ether device whitelist,
> >> enabling access to the modem.
> >> 
> >> I would think more SE models of this generation
> >> (2009Q3) with builtin HSDPA modules also needs
> >> to be added to this list.
> >
> > I do prefer if we NOT use the mbm_info details for this since they are
> > clearly for mobile broadband cards with FLAG_WWAN.
> 
> Assuming that these devices can be configured just like the WWAN cards
> by sending commands to the associated ACM* or WDM* interfaces, why would
> you treat them differently?  Because they've got a keyboard and a
> display?

these are not like MBM devices WWAN cards. The MBM cards require to
setup the PDP context before the card will become ready. With an actual
phone you are already set.

So these are Ethernet devices and not WWAN cards.

> > Since this is a phone where the setup of the connection is done via the
> > phone. And you just treat this as an Ethernet device and run DHCP, then
> > please create a se_info or similar with FLAG_ETHER.
> 
> Why would anyone want to setup the connection via the phone?  That seems
> unnecessary cumbersome. I'd prefer such devices to be auto-configured
> just like any other WWAN device.

Are they WWAN devices? What these do is basically tethering via an
Ethernet like device. It does not require a telephony stack to drive
this hardware.

We require a proper DEVTYPE classification and these don't fall into the
category of WWAN devices. They can be treated like every other Ethernet
card and should be classified like this. We have FLAG_ETHER for this, so
please use that one.

Regards

Marcel


