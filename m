From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Linux support for 802.3af?
Date: Sat, 13 Mar 2010 04:40:03 +0000
Message-ID: <1268455203.7439.78.camel@localhost>
References: <4B9AD5CA.7000303@redfish-solutions.com>
	 <1268440985.7439.23.camel@localhost>
	 <4B9AE62B.6050502@redfish-solutions.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "Philip A. Prindeville" <philipp_subx@redfish-solutions.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:3803 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754720Ab0CMEkI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Mar 2010 23:40:08 -0500
In-Reply-To: <4B9AE62B.6050502@redfish-solutions.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-03-12 at 18:11 -0700, Philip A. Prindeville wrote:
> On 03/12/2010 05:43 PM, Ben Hutchings wrote:
> > On Fri, 2010-03-12 at 17:01 -0700, Philip A. Prindeville wrote:
> >> I was looking at this Marvell-based 4-port PCI card with PoE and
> >> thinking it would be handy for powering cameras and ip-phones, but don't
> >> remember seeing any kernel support for 802.3af...
> >>
> >> http://www.korenix.com/jetcard-PoE_Universal_PCI_Card-2215-overview.htm
> >>
> >> There's no support for 802.3af, right?
> > 
> > The standard MDIO ioctls can be used to access registers 11 and 12 on
> > PHYs with integrated PSE functionality.  There is no way of indicating
> > whether a PHY has such functionality, but a flag for this could be added
> > to the mdio_support field of struct ethtool_cmd.
> > 
> > Ben.
> 
> Well, there's more to it than that, right?
> 
> There's a software state machine that's required to go through the
> handshake, there's prioritization and power budgeting, etc.  Yes?
> 
> What am I missing?

We seem to have contrary expectations of how a PSE would be implemented.
You assume that the CPU would be involved at quite a low level.  I
assume that a PSE in a Linux system would be implemented on a peripheral
device and that it would be managed from the host via MDIO (though this
is specified as an optional feature).

Looking at the specs, that particular card is using a Marvell switch
chip which doesn't have any PoE support, so management via MDIO seems
unlikely.  If you're curious I suppose you should try to get the driver
from this vendor.

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

