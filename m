From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specificqdisc
Date: Fri, 3 Nov 2006 11:29:33 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B5FB0@dhost002-46.dex002.intermedia.net>
References: <C86180A8C204554D8A3323D8F6B0A29F018B5FAE@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "Christoph Hellwig" <hch@infradead.org>,
	"James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:36240 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1753486AbWKCT3R convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Nov 2006 14:29:17 -0500
Content-class: urn:content-classes:message
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B5FAE@dhost002-46.dex002.intermedia.net>
To: "Simon Barber" <simon@devicescape.com>,
	"Johannes Berg" <johannes@sipsolutions.net>,
	"Stephen Hemminger" <shemminger@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I should elaborate - if 802.11 is made into a real protocol - then raw
packet capture works correctly on the master device. (raw sockets opened
on the device see all frames before they are passed to the protocol).
This is the right way to go.

Simon 

-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Simon Barber
Sent: Friday, November 03, 2006 11:24 AM
To: Johannes Berg; Stephen Hemminger
Cc: Christoph Hellwig; James Ketrenos; John W. Linville; Jeff Garzik;
Patrick McHardy; David Kimdon; netdev@vger.kernel.org
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather
thand80211-specificqdisc

I'm not sure why we don't use the master device for packet capture - I
can't think of any good reason for requiring a separate device. I would
think the master device is the perfect place to do packet capture, and
raw packet transmission.

Simon 

-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net]
Sent: Thursday, November 02, 2006 2:57 PM
To: Stephen Hemminger
Cc: Simon Barber; Christoph Hellwig; James Ketrenos; John W. Linville;
Jeff Garzik; Patrick McHardy; David Kimdon; netdev@vger.kernel.org
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather
thand80211-specificqdisc

On Thu, 2006-11-02 at 14:34 -0800, Stephen Hemminger wrote:

> It makes 802.11 packet capture easier as well.  Please don't invent 
> yet another network access object for the master device.

Oh, but the master device doesn't get any packets you could capture. For
that, you need to add a monitor interface.

johannes
-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
