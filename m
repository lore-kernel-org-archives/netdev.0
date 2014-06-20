From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Subject: [PATCH RFC 00/30] Initial round of Freescale FEC ethernet patches
Date: Fri, 20 Jun 2014 13:11:18 +0100
Message-ID: <20140620121118.GR32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Fugang Duan <B38611@freescale.com>, netdev@vger.kernel.org
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw-1.arm.linux.org.uk ([78.32.30.217]:36314 "EHLO
	pandora.arm.linux.org.uk" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S966820AbaFTMLY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jun 2014 08:11:24 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is my initial round of patches (roughly half of my total patch
set) for the Freescale FEC driver.

I'm sending this set out initially for comments and testing.  One of
my motivations for only sending half is to get this half into a state
where DaveM is happy to merge it before I sort out the remainder.
There's quite a lot here, so bear with me on this.

I've tried to sort the fixes before the cleanups as best I can, but
reordering the series is a full-time job due to it's size - it's taken
from Monday until now to get this far with it, so I'm hoping that there
won't be any "you should rearrange the patches as X" comments.

While the original series was well tested during it's original
development, including with performance tests on each patch, that
testing and validation has been lost due to the changes during the
last merge window, and subsequent rebasing and updating of the patches.

The series is based on v3.16-rc1, and as such, I have added Andy's
checksum fix to the start of the series.  This patch is not strictly
part of the RFC, but is included because my complete patch series needs
to account for that change.

Some of these patches are to fix theoretical problems in the driver
(ones which have been found via a review of the code) others address
real observable problems (such as poor half-duplex performance.)

Towards the end of this series, I have included a patch which was
initially at the beginning of the series for dumping out the state of
the transmit ring, which is very useful to debug transmit problems.
This was acceptable when the transmit ring was between 16 and 128
descriptors, but during the recent merge window, this was increased to
512 descriptors, so it will now print around 512 lines to the kernel
message log on transmit timeout.  I'm not entirely convinced this is a
good idea - maybe it should become optional, or maybe the timed-out ring
status should be available via debugfs, but that's a problem to retrieve
if you're running NFS rootfs and the timeout doesn't recover properly.

This series of patches is also available from the following *unstable*
git branch - unstable as it's provided for convenience so you don't
have to apply all these patches individually, unstable as the patches
need to have attributations added, unstable because DaveM will probably
want to apply them as patches to his tree:

  git://ftp.arm.linux.org.uk/~rmk/linux-arm.git fec-testing

 drivers/net/ethernet/freescale/fec.h      |  10 +-
 drivers/net/ethernet/freescale/fec_main.c | 383 +++++++++++++++++-------------
 2 files changed, 225 insertions(+), 168 deletions(-)

-- 
FTTC broadband for 0.8mile line: now at 9.7Mbps down 460kbps up... slowly
improving, and getting towards what was expected from it.
