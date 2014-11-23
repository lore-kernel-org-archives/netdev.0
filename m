From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next] vlan: Pass ethtool get_ts_info queries to real
 device.
Date: Sun, 23 Nov 2014 17:05:35 +0100
Message-ID: <20141123160533.GA4562@netboy>
References: <1416575780-19132-1-git-send-email-richardcochran@gmail.com>
 <1416712512.7215.34.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	Stefan =?iso-8859-1?Q?S=F8rensen?=
	<stefan.sorensen@spectralink.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f42.google.com ([74.125.82.42]:55895 "EHLO
	mail-wg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751273AbaKWQFl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Nov 2014 11:05:41 -0500
Received: by mail-wg0-f42.google.com with SMTP id z12so10316566wgg.1
        for <netdev@vger.kernel.org>; Sun, 23 Nov 2014 08:05:40 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1416712512.7215.34.camel@decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Nov 23, 2014 at 03:15:12AM +0000, Ben Hutchings wrote:
> This assumes that the same PTP capabilities apply to VLAN-tagged frames.
> I don't think it's at all safe to assume that RX filter modes other than
> HWTSTAMP_FILTER_ALL will include VLAN-tagged frames.  I think it is
> necessary to define additional modes that explicitly include VLAN-tagged
> frames.

Unsafe? How?

Do you mean that some HW cannot identify and time stamp PTP frames
when VLAN tagged? That is surely disappointing for people who shell
out money for such cards, but it is hardly unsafe.

> I also disagree in general that reconfiguring a VLAN device should make
> changes to the underlying device that affect more than just that VLAN,
> i.e. SIOCSHWTSTAMP should not be passed through.  SIOCGHWTSTAMP could be
> passed through, but rx_filter would need adjustment (VLAN-tagged modes
> on the underlying devices become untagged modes on the VLAN device).

The whole filter list with every last combination (at least, the ones
at the time) came directly from a early, limited HW design.  Sane,
modern PTP hardware provides time stamps regardless of whether a frame
is VLAN tagged or not. I don't see any reason not to make our stack
even more ugly just to cater to broken hardware.

I have nothing against adding VLAN to the SIOCGHWTSTAMP list, because
the hardware people *really* use all have:

	HWTSTAMP_TX_ON, and
	HWTSTAMP_FILTER_ALL, or 
	HWTSTAMP_FILTER_PTP_V2_EVENT,

So adding more won't hurt. (But it won't help either. If your HW
cannot time stamp Layer2 and you transmit Layer2, you simply never get
a time stamp.)

But please don't hold up progress just for this sort of thing.

Thanks,
Richard
