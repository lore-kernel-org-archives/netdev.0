From: Jiri Benc <jbenc@suse.cz>
Subject: Re: [patch] d80211: use pfifo_qdisc_ops rather than d80211-specific
 qdisc
Date: Wed, 1 Nov 2006 11:28:05 +0100
Message-ID: <20061101112805.246e1b3b@griffin.suse.cz>
References: <20061026050416.GB14199@havoc.gtf.org>
	<C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Jeff Garzik" <jeff@garzik.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"David Kimdon" <dwhedon@devicescape.com>, <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from styx.suse.cz ([82.119.242.94]:11704 "EHLO mail.suse.cz")
	by vger.kernel.org with ESMTP id S1946597AbWKAK2I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 05:28:08 -0500
To: "Simon Barber" <simon@devicescape.com>
In-Reply-To: <C86180A8C204554D8A3323D8F6B0A29F018B54FB@dhost002-46.dex002.intermedia.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Oct 2006 22:15:23 -0700, Simon Barber wrote:
> Re: registering as a real protocol - yes this I have been going on about
> for a while. This needs a few changes in how things work:
> 
> 1. Register as a real protocol.
> 2. Change drivers to use netif_rx to receive frames (will also be more
> efficient)

This is something I really want too.

However, the biggest problem is bridging. A lot of people bridge their
ethernet and wifi interfaces together. We'll need to change the
bridging code to make it possible again.

> I would also like to see:
> 
> Drivers to use register_netdev - not special ieee80211 register to
> register themselves

I don't see a benefit in this, but well, let's consider it when there
is a patch.

> Drivers to use a normal hard_start_xmit function
> - need to move 802.11 pre xmit frame processing into the qdisc dequeue
> function

Agreed. It's not a priority, though.

> Get rid of gunky beacon & multicast buffered frame handling - make them
> into normal queues like everything else (so same hard_start_xmit can be
> used).

I'm not sure about beacons here - don't some drivers need to handle
them specially?

Thanks,

 Jiri

-- 
Jiri Benc
SUSE Labs
