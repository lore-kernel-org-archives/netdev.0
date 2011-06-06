From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [E1000-devel] [PATCH] e100: Fix inconsistency in bad frames
 handling
Date: Mon, 06 Jun 2011 21:15:15 +0100
Message-ID: <1307391315.22348.454.camel@localhost>
References: <BANLkTimpYniHhN6ccMXN7Lx3xDdK6sC+FQ@mail.gmail.com>
	 <alpine.WNT.2.00.1106060940010.3568@JBRANDEB-DESK2.amr.corp.intel.com>
	 <4DED14E7.2050405@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	Andrea Merello <andrea.merello@gmail.com>,
	"e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:29715 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754007Ab1FFUPS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 16:15:18 -0400
In-Reply-To: <4DED14E7.2050405@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2011-06-06 at 10:56 -0700, Ben Greear wrote:
> On 06/06/2011 10:49 AM, Brandeburg, Jesse wrote:
> >
> > <added netdev>, removed other useless lists.
> >
> > On Sat, 4 Jun 2011, Andrea Merello wrote:
> >> In e100 driver it seems that the intention was to accept bad frames in
> >> promiscuous mode and loopback mode.
> >> I think this is evident because of the following code in the driver:
> >>
> >> if (nic->flags&  promiscuous || nic->loopback) {
> >> 		config->rx_save_bad_frames = 0x1;	/* 1=save, 0=discard */
> >> 		config->rx_discard_short_frames = 0x0;	/* 1=discard, 0=save */
> >> 		config->promiscuous_mode = 0x1;		/* 1=on, 0=off */
> >> 	}
> >>
> >
> > Hi, thanks for your work on e100.
> >
> >> However this intention is not really realized because bad frames are
> >> discarded later by SW check.
> >> This patch finally honors the above intention, making the RX code to
> >> let bad frames to pass when the NIC is in promiscuous or loopback
> >> mode.
> >
> > I think this may be a mistake by the authors of the software developers
> > manual.  The manual suggests that save bad frames and save short frames
> > should be enabled in promisc mode, but all of our other drivers *do not*
> > save bad frames when in promiscuous mode (by design).  This is intentional
> > because a bad frame is just that, bad, and with no hope of knowing if the
> > data in it is okay/malicious/other.  I understand your reasoning above,
> > but realistically the rx_save_bad_frames should NOT be set.  I'd ack a
> > patch to comment that line out.
> >
> >> This helped me a lot to debug an FPGA ethernet core.
> >> Maybe it can be also useful to someone else..
> >
> > I think this patch is just that, debug only. As a developer I understand
> > why this is useful, but there is no reason any normal user would be able
> > to benefit from this, so for now, sorry:
> >
> > NACK.
> 
> I think anyone sniffing a funky network would have benefit in
> receiving all frames.  So, while it shouldn't be enabled by default,
> it would be nice to have an ethtool command to turn on receiving
> bad-crc frames, as well as receiving the 4-byte CRC on the end of
> the packets.
> 
> It just so happens I have such a patch, in case others agree :)

How would a received skb be flagged as having a CRC error?

Ben.

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

