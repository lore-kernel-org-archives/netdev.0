From: Greg KH <gregkh@suse.de>
Subject: [patch 04/47] ssb: Fix context assertion in
	ssb_pcicore_dev_irqvecs_enable
Date: Fri, 13 Jun 2008 17:10:23 -0700
Message-ID: <20080614001023.GD24698@suse.de>
References: <20080613234753.235721454@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>, Willy Tarreau <w@1wt.eu>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Michael Buesch <mb@bu3sch.de>,
	"John W. Linville" <linville@tuxdriver.com>,
	Chris Wright <chrisw@sous-sol.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:51612 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758975AbYFNAM2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 13 Jun 2008 20:12:28 -0400
Content-Disposition: inline; filename="ssb-fix-context-assertion-in-ssb_pcicore_dev_irqvecs_enable.patch"
In-Reply-To: <20080614000840.GA24659@suse.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Michael Buesch <mb@bu3sch.de>

upstream commit: a3bafeedfff2ac5fa0a316bea4570e27900b6fcc

This fixes a context assertion in ssb that makes b44 print
out warnings on resume.

This fixes the following kernel oops:
http://www.kerneloops.org/oops.php?number=12732
http://www.kerneloops.org/oops.php?number=11410

Signed-off-by: Michael Buesch <mb@bu3sch.de>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
Signed-off-by: Chris Wright <chrisw@sous-sol.org>

---
 drivers/ssb/driver_pcicore.c |    4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

--- a/drivers/ssb/driver_pcicore.c
+++ b/drivers/ssb/driver_pcicore.c
@@ -519,12 +519,12 @@ int ssb_pcicore_dev_irqvecs_enable(struc
 	int err = 0;
 	u32 tmp;
 
-	might_sleep();
-
 	if (!pdev)
 		goto out;
 	bus = pdev->bus;
 
+	might_sleep_if(pdev->id.coreid != SSB_DEV_PCI);
+
 	/* Enable interrupts for this device. */
 	if (bus->host_pci &&
 	    ((pdev->id.revision >= 6) || (pdev->id.coreid == SSB_DEV_PCIE))) {

-- 
