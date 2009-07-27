From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Mon, 27 Jul 2009 19:59:50 +0200
Message-ID: <1248717590.28545.209.camel@violet>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <200907241431.08858.oliver@neukum.org>
	 <20090724134805.0d9496be@lxorguk.ukuu.org.uk>
	 <200907241612.41871.oliver@neukum.org>  <1248458401.28545.149.camel@violet>
	 <1248716166.17189.25.camel@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Oliver Neukum <oliver@neukum.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Dan Williams <dcbw@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:57176 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751353AbZG0SAz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Jul 2009 14:00:55 -0400
In-Reply-To: <1248716166.17189.25.camel@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dan,

> > > > > No, I was thinking of having two full devices, a data channel and a
> > > > > control channel for devices that really talk AT commands natively.
> > > >
> > > > If the hardware does it great, however for things like a 3G modem you
> > > > have the problem that the PPP is over the AT command channel which may
> > > > itself be multiplexed. And the muxing in question is *ugly* - sort of
> > > > HDLC and LAP-B done wrong.
> > > 
> > > Well, yes, but we would really like a separate control channel, so we
> > > can query parameters like signal strength, while we do PPP over the data
> > > channel.
> > 
> > we don't want PPP at all. It is just plain stupid and a total braindead
> > idea. Non of the GSM/UMTS networks talk PPP over the air interface or
> > actually anywhere in their stack. The PPP is just between the host OS
> > and the card. It is a pointless encapsulation of IP packets that comes
> > from the POTS stuff where PPP over a telephone line made sense.
> 
> Feel free to convince all the hardware vendors to move over to that
> model.  Many of them are, but there are still *boatloads* of devices
> that do PPP.  It'll be at least 3 or 4 years before you can even think
> about ignoring PPP entirely.
> 
> This is totally a firmware thing and not something under our control at
> all.  Either the vendor implements a non-PPP data channel, or they
> don't.  We have to live with that, or ignore devices that use PPP.  Most
> of the devices out there use PPP.  Maybe 80 or 90%.

I know that and it is sad. It is also sad that a firmware upgrade could
bring most cards away from PPP, but besides Option I haven't seen it
from anybody.

> The only reason vendors ditched PPP was that it was too much overhead to
> achieve full speed on HSDPA 7.2 networks.  Guess how many operators have
> actually deployed HSDPA 7.2?  Count them on your hands.  Yes, over the
> next year or two we'll see a lot more HSDPA 7.2-capable networks, and
> that means more devices will show up that ditch PPP.  But at the moment,
> PPP can't be ignored.

Actually HSDPA 7.2 is deployed more than you think. At least in Europe
the base stations in the big cities are 7.2 capable. Some of them even
with proper HSUPA support. It is impressive what you can get through
these networks.

> The next problem is that not all vendors implement the non-PPP data
> channel using cdc-ether, or provide specs/drivers for that channel.  So
> just because a vendor ditches PPP doesn't automatically mean it's better
> for Linux and a driver is available.

The CDC Ethernet support of the Ericsson MBM cards is kinda a nice idea.
You get proper IFF_LOWER_UP and can just run DHCP on it. I am not such a
big fan of the DHCP part, but it is the same for WiMAX, so I assume that
is what they will be settling for. Nice would to have just plain and
simple IPv6 on UMTS networks.

Regards

Marcel


