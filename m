From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: [PATCH] (1/8) hdlc wan device disembedding
Date: Wed, 03 Dec 2003 00:03:30 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <m3k75eddq5.fsf@defiant.pm.waw.pl>
References: <20031202140103.6bb2deb4.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20031202140103.6bb2deb4.shemminger@osdl.org> (Stephen
 Hemminger's message of "Tue, 2 Dec 2003 14:01:03 -0800")
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger <shemminger@osdl.org> writes:

> Change the hdlc wan device's to not have the net_device structure embedded
> inside the hdlc_device structure.  This won't work on 2.6 where the
> net_device
> structure may need to live after module unload due to sysfs.
> Instead, use alloc_netdev and setup so that netdev->priv = hdlc 
> and have hdlc->dev_data for device private data.

Hmm... I always wanted dev->priv to be available for hw drivers (and
yes, PPP proto doesn't currently meet that).

Any other idea maybe?


It seems the whole WAN (drivers/net/wan) needs some major rewrite, as
the recent patches (starting with last 2.5.x ones) have broken few
things (at least for me) which are not all fixed.

First I would duplicate syncppp.c code in hdlc_ppp.c (removing Cisco HDLC
support and polishing it to suit generic HDLC needs) so it no longer
depends on syncppp (long-term I plan switching to generic PPP but it's
certainly post-2.6 thing and I'm not even sure how to do it).
This would result in few hundred lines of duplicated code, though.

The positive side is that I can test the generic HDLC + hw drivers for
C101, N2, wanXL, PCI200SYN (being merged) and PC300.


The other thing would be converting drivers using syncppp.c to use
generic HDLC instead (it would add support for X.25, Frame-Relay and
raw HDLC). While I can probably make a patch I can't test it.

The remaining drivers use either Sangoma (sdla/dlci/wanpipe/wanrouter)
or comx code. Not sure about their status, are they both maintained?

Comments?
-- 
Krzysztof Halasa, B*FH
