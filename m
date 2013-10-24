From: Leigh Brown <leigh@solinno.co.uk>
Subject: [PATCH RFC v2 0/4] MDIO bus timeout issues on Dreamplug
Date: Thu, 24 Oct 2013 19:09:30 +0100
Message-ID: <cover.1382637156.git.leigh@solinno.co.uk>
References: <cover.1382199042.git.leigh@solinno.co.uk>
Cc: Leigh Brown <leigh@solinno.co.uk>,
	Thomas Petazzoni <thomas.petazzoni@free-electrons.com>,
	netdev@vger.kernel.org, sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from doppler.thel33t.co.uk ([193.110.88.198]:51337 "EHLO
	doppler.thel33t.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755523Ab3JXSKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Oct 2013 14:10:10 -0400
In-Reply-To: <cover.1382199042.git.leigh@solinno.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks to the comment from Sebastian I did some more investigation and
discovered that almost everything about my analysis was wrong (woops).
The patch itself wasn't too bad though.

In terms of timings, I don't believe the timeout was due to the SMI bus
taking too long to respond because when I have repeated my testing
(this time disabling interrupts whilst waiting), I have found that the
maximum time that my Dreamplug takes to respond was about 95us (and
43us on the Mirabox, which polls).  So I think the root cause of the 
problem was that interrupt handler was interfering with the polling in 
some way.

I have therefore amended the first patch to use usleep_range to sleep
instead of busy wait as suggested by Sebastian, and set the timeout to
1ms.  I've tested this on both the Dreamplug and Mirabox and have seen
no timeouts at all.

The second, third and fourth patches are pretty much the same as before.

If I receive no comments who do I submit this to for inclusion?

Regards,

Leigh.

Leigh Brown (4):
  net: mvmdio: make orion_mdio_wait_ready consistent
  net: mvmdio: orion_mdio_ready: remove manual poll
  net: mvmdio: slight optimisation of orion_mdio_write
  net: mvmdio: doc: mvmdio now used by mv643xx_eth

 drivers/net/ethernet/marvell/mvmdio.c |  107 ++++++++++++++++-----------------
 1 file changed, 52 insertions(+), 55 deletions(-)

-- 
1.7.10.4
