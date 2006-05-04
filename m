From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [PATCH] bcm43xx-d80211: proper implementation of virtual
 interface support
Date: Fri, 5 May 2006 00:22:15 +0200
Message-ID: <20060505002215.1972e12b@logostar.upir.cz>
References: <200605012135.00895.mb@bu3sch.de>
	<20060502132037.059a7cb2@griffin.suse.cz>
	<e3dkfd$pc5$1@sea.gmane.org>
	<200605042256.02333.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Marcus Better <marcus@better.se>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from r2u241.chello.upc.cz ([62.245.84.241]:37760 "EHLO
	localhost.localdomain") by vger.kernel.org with ESMTP
	id S1750770AbWEDWWS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 18:22:18 -0400
To: Ivo van Doorn <ivdoorn@gmail.com>
In-Reply-To: <200605042256.02333.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thu, 4 May 2006 22:55:58 +0200, Ivo van Doorn pise:
> On Thursday 4 May 2006 21:26, Marcus Better wrote:
> > I wonder what exactly is causing this limitation? Why isn't it just a
> > matter of software support?
> 
> Hardware limitations probably. For example the Ralink devices.
> The MAC address must be written into the registers for correct behaviour.
> When multiple virtual interfaces are going to be used, the device
> should be working under multiple MAC addresses. While the device
> could be tricked into doing that (I believe rt61 and rt73 drivers from
> Ralink are making such an attempt) it could give quite some overhead when
> for each frame that is being send the driver should sort out from which
> virtual interface it came, write the matching MAC address to the register,
> and hope that the device will like it when the MAC address is changed so
> often and the RX is not being affected because of some hardware filter.

The actual problem is with receiving. ACK frames need to be sent exactly
after SIFS interval (10 or 16 microseconds depending on a PHY, +/- 10%)
after last bit of the frame was received. This means it cannot be done in a
software. You need to tell the hardware about MAC address you are using and
hardware will ACK all frames destined to that address (well, actually only
that received with valid FCS, but it doesn't matter). And most hardware
don't allow to specify more MAC addresses.

 Jiri

-- 
Jiri Benc
SUSE Labs
