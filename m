From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: Re: [PATCH 14/39] i2400m: documentation and instructions for usage
Date: Tue, 2 Dec 2008 18:06:49 -0800
Message-ID: <200812021806.50245.inaky@linux.intel.com>
References: <cover.1227691434.git.inaky@linux.intel.com> <35dc01f4362676409dd3bf18095ee2ffcef1acce.1227691434.git.inaky@linux.intel.com> <1227780100.3809.52.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga07.intel.com ([143.182.124.22]:39507 "EHLO
	azsmga101.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754015AbYLCCLb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Dec 2008 21:11:31 -0500
In-Reply-To: <1227780100.3809.52.camel@johannes.berg>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 27 November 2008, Johannes Berg wrote:
> On Wed, 2008-11-26 at 15:07 -0800, Inaky Perez-Gonzalez wrote:
> > +$ cp FIRMWAREFILE.sbcf /lib/firmware/i2400m-fw-BUSTYPE-1.3.sbcf
> > +
> > +     * NOTE: if your firmware came in an .rpm or .deb file, just install
> > +       it as normal, with the rpm (rpm -i FIRMWARE.rpm) or dpkg
> > +       (dpkg -i FIRMWARE.deb) commands. No further action is needed.
> > +     * BUSTYPE will be usb or sdio, depending on the hardware you have.
> > +       Each hardware type comes with its own firmware and will not work
> > +       with other types.
>
> Can that be put into the firmware tree David Woodhouse maintains?

Yes, it will. There is a linux-firmware-wimax tree I'll ask David to pull
from.

> > +Controlling the device through sysfs
> > +
> > +   sysfs files to control the device behaviour are located in the
> > +   per-device directories /sys/class/net/wmxX*:
> > +
> > +$ cd /sys/class/net/wmx0
> > +$ ls -1 wimax/* i2400m*
> > +i2400m_debug
> > +i2400m_debug_levels
> > +i2400m_reset_cold
> > +i2400m_reset_warm
> > +i2400m_rx_stats
> > +i2400m_suspend
> > +i2400m_trace_msg_from_user
> > +i2400m_tx_stats
> > +i2400m_usb_debug_levels
> > +wimax/debug_levels
> > +wimax/gnl_family_id
> > +wimax/gnl_version
>
> Are any of those actually needed for normal operation, and cannot be in
> debugfs instead?

Actually some of them could. I'll see to put them.

The reset ones I want to keep in there, as for support they come in 
very handy.

> > +RX and TX statistics
> > +
> > +   This file provides with statistics about the data reception from the
> > +   device:
> > +
> > +$ cat /sys/class/net/wmx0/i2400m_rx_stats
> > +45 1 3
> > +34 3104 48 480
> > +
> > +   The numbers reported are
> > +     * packets/RX-buffer: total, min, max
> > +     * RX-buffers: total RX buffers received, accumulated RX buffer size
> > +       in bytes, min size received, max size received
> > +
> > +   Thus, to find the average buffer size received, divide accumulated
> > +   RX-buffer / total RX-buffers.
> > +
> > +   To clear the statistics back to 0:
>
> Couldn't statistics be in some more generic wimax file rather than per
> driver?

Very driver specific. These statistics refer to the way the device sends
and receives stuff, which is coalesced (so one of this packets doesn't map
to an IP packet).

This one belongs to debugfs.


-- 
Inaky

