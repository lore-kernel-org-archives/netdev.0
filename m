From: "Simon Barber" <simon@devicescape.com>
Subject: RE: [patch] d80211: use pfifo_qdisc_ops rather thand80211-specific qdisc
Date: Thu, 2 Nov 2006 08:33:57 -0800
Message-ID: <C86180A8C204554D8A3323D8F6B0A29F018B5DE3@dhost002-46.dex002.intermedia.net>
References: <1162477358.10786.4.camel@ux156>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "James Ketrenos" <jketreno@linux.intel.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	"Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-46.dex002.intermedia.net ([64.78.21.140]:8226 "EHLO
	dhost002-46.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S1751981AbWKBQdn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2006 11:33:43 -0500
Content-class: urn:content-classes:message
In-Reply-To: <1162477358.10786.4.camel@ux156>
To: "Johannes Berg" <johannes@sipsolutions.net>,
	"Christoph Hellwig" <hch@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There are many reasons to have the master device - and many reasons not
to get rid of it. The only excpetion is when using a limited fullmac
card.  Some fullmac cards only support a single ethernet interface, so
for these cards a single device may be OK, if we want to allow multiple
different appearences for different types of card (a bad thing in my
book). (Note - older prism 54g fullmac cards support WDS, hence need
multiple interfaces).

The master interface represents the physical networking device that
works using native 802.11 frames. The qdisc works on 802.11 frames - not
ethernet, and it can change how 802.11 management frames are queued. It
can only be got rid of in the case of a fullmac card with only a single
interface, where all management frames are processed in the card.

In addition as we move to make 802.11 devices native (i.e. create an
802.11 protocol) the 802.11 master interface will be essential.

I don't see the problem with 802.11 master devices - they are not
ethernet devices, and should not confuse any user space. Any user space
that gets confused by netdevices with arp-hdr types that they do not
recognise is broken, and needs to be fixed.

Simon


-----Original Message-----
From: Johannes Berg [mailto:johannes@sipsolutions.net] 
Sent: Thursday, November 02, 2006 6:23 AM
To: Christoph Hellwig
Cc: James Ketrenos; John W. Linville; Simon Barber; Jeff Garzik; Patrick
McHardy; David Kimdon; netdev@vger.kernel.org
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather
thand80211-specific qdisc

On Thu, 2006-11-02 at 15:05 +0100, Jiri Benc wrote:
> - Single device is not as easy as it sounds. It would require rather
>   invasive changes in the networking core or ugly hacks in d80211. I'm
>   afraid this is something not achievable in a near future with
current
>   number of people working on d80211. But in general, it's doable and
>   desirable, yes.

Actually, just as a note to all the others (talked to Jiri about it
already), I think it's easier than thought since the code is so
convoluted. The only purpose of the wmaster device appears to be to have
an outgoing frame queue through the qdisc. Since we require the 802.11
qdisc to be installed at the root for all netdevices anyway, we could
just as well hand the frame to it right away.

I'll look into that later today.

johannes
