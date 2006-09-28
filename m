From: "Jouni Malinen" <jkm@devicescape.com>
Subject: Re: kernel: TKIP: replay detected:
Date: Thu, 28 Sep 2006 09:08:34 -0700
Message-ID: <20060928160834.GC9615@instant802.com>
References: <20060924104053.GA6645@frodo.home.lxtec.de> <20060925144954.GC16949@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dhost002-45.dex002.intermedia.net ([64.78.21.137]:41081 "EHLO
	dhost002-45.dex002.intermedia.net") by vger.kernel.org with ESMTP
	id S932462AbWI1QIj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 12:08:39 -0400
To: "John W. Linville" <linville@tuxdriver.com>
Content-Disposition: inline
In-Reply-To: <20060925144954.GC16949@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 25, 2006 at 10:50:00AM -0400, John W. Linville wrote:
> On Sun, Sep 24, 2006 at 12:40:53PM +0200, Elimar Riesebieter wrote:

> > My sylog is filled up with thousands of:
> > Sep 21 18:18:00 aragorn kernel: TKIP: replay detected: \
> > STA=XX:XX:BB:LL:KK:00 previous TSC 00000000BLAa received TSC 00000000BLAa

> Opinion seems to be running that these messages are useless and should
> be removed.  Anyone disagree?

Yes, I disagree (again). In most cases, these are indication of an
implementation error. The problem here is that this issue may be at the
end of the connection. Anyway, if we are seeing large numbers of replays
detected with the same TSC/PN, I would suggest verifying that the IEEE
802.11 duplicate detection is working correctly in the driver that is
reporting these replays.

TKIP/CCMP are required to use incrementing TSC/PN for each frame. When a
directed IEEE 802.11 frame is not acknowledged, it will be retransmitted
(up to a certain limit). This retransmitted frame will use the same
TSC/PN. However, the duplicate detection routine in the receiver
(something that happens before TKIP/CCMP processing) should catch these
cases since the frames from the same source address that use the same
seq# and fragm# should be dropped at that layer.

If it can be shown, that these errors are indeed caused by a broken
transmitter (and that transmitter is not a Linux device for which we
control the driver code ;-), I would be much more willing to accept
patches that silence these messages (as long as the replay statistics
are easily available in other ways) by default, but I would still not
remove them completely.

-- 
Jouni Malinen                                            PGP id EFC895FA
