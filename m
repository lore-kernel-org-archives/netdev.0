From: Marcel Holtmann <marcel@holtmann.org>
Subject: Re: [PATCH] USB host CDC Phonet network interface driver
Date: Fri, 24 Jul 2009 20:00:01 +0200
Message-ID: <1248458401.28545.149.camel@violet>
References: <1248177515-12712-1-git-send-email-remi.denis-courmont@nokia.com>
	 <200907241431.08858.oliver@neukum.org>
	 <20090724134805.0d9496be@lxorguk.ukuu.org.uk>
	 <200907241612.41871.oliver@neukum.org>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Alan Cox <alan@lxorguk.ukuu.org.uk>,
	=?ISO-8859-1?Q?R=E9mi?= Denis-Courmont
	<remi.denis-courmont@nokia.com>,
	ext Dan Williams <dcbw@redhat.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-usb@vger.kernel.org" <linux-usb@vger.kernel.org>
To: Oliver Neukum <oliver@neukum.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:36481 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753723AbZGXSAv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 14:00:51 -0400
In-Reply-To: <200907241612.41871.oliver@neukum.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Oliver,

> > > No, I was thinking of having two full devices, a data channel and a
> > > control channel for devices that really talk AT commands natively.
> >
> > If the hardware does it great, however for things like a 3G modem you
> > have the problem that the PPP is over the AT command channel which may
> > itself be multiplexed. And the muxing in question is *ugly* - sort of
> > HDLC and LAP-B done wrong.
> 
> Well, yes, but we would really like a separate control channel, so we
> can query parameters like signal strength, while we do PPP over the data
> channel.

we don't want PPP at all. It is just plain stupid and a total braindead
idea. Non of the GSM/UMTS networks talk PPP over the air interface or
actually anywhere in their stack. The PPP is just between the host OS
and the card. It is a pointless encapsulation of IP packets that comes
from the POTS stuff where PPP over a telephone line made sense.

And on top of that we have these magic *99# phone numbers to establish a
PDP context, because the OS still sees them as POTS modem. All stupid
and braindead. I am so happy that Ericsson and Option moved to proper
high speed network devices and that Nokia Phonet had this all along.

So besides the GPRS data access, the other problem with AT command
control channels is that they are by no means async. Every single
command is essentially blocking and so you need the TTY mux anyway so
you can do scanning, text messaging and network monitoring at the same
time without having your application look like a total dork.

Regards

Marcel


