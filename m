From: "Kok, Auke" <auke-jan.h.kok@intel.com>
Subject: [PATCH 00/22] ixgb, e1000 fixes
Date: Fri, 08 Dec 2006 15:02:09 -0800
Message-ID: <20061208230209.30109.49157.stgit@gitlost.site>
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke-jan.h.kok@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from [63.64.152.142] ([63.64.152.142]:4351 "EHLO gitlost.site"
	rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1761251AbWLHWwC (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 17:52:02 -0500
To: "Garzik, Jeff" <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

This patch series contains exclusively fixes for ixgb and e1000. Most
importantly, it addresses two issues in the recently merged msi interrupt
handler and dynamic itr code, as well as some major manageability
feature handling code.

These patches apply against netdev-2.6 #upstream-linus commit
0ae851352a87db3f829511816a2da227860bf585. Please pull:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream-linus

to receive them.

Cheers,

Auke

---
Bruce Allan <bruce.w.allan@intel.com>:
     e1000: Fix PBA allocation calculations
     e1000: set max frame size before enabling new link settings

Jesse Brandeburg <jesse.brandeburg@intel.com>:
     e1000: Fix early TSO completion
     ixgb: Maybe stop TX if not enough free descriptors
     e1000: dynamic itr code fixes
     e1000: minor tso ipv6 cleanups
     e1000: omit stats for broken counter in 82543
     e1000: Fix all manageability workarounds
     e1000: Make copybreak parameter changeable by user.
     e1000: Fire a link even interrupt instead of a watchdog at init.
     e1000: Fix powerdown link loss when forced to gig speed
     e1000: disable TSO when debugging slab
     e1000: always turn on receives on esb2
     e1000: simplify msi specific interrupt handler
     e1000: Rewrite parm handling code to warn when forcing autoneg to gig only.
     e1000: Don't set tipg (fiber) timings for pci-e adapters to fix fiber output
     e1000: Fix poor quad port performance with NAPI

Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
     e1000: For older adapters, we know that the pci bus type is pci.

Auke Kok <auke-jan.h.kok@intel.com>:
     e1000: display FC link properties
     e1000: Version increment 7.3.20-k2 and minor cleanups

Aaron Salter <aaron.k.salter@intel.com>:
     ixgb: Write RA register high word first, increment version

---
 drivers/net/e1000/e1000.h         |    7 +-
 drivers/net/e1000/e1000_ethtool.c |    3 +
 drivers/net/e1000/e1000_hw.c      |   59 +++---
 drivers/net/e1000/e1000_hw.h      |    2 +
 drivers/net/e1000/e1000_main.c    |  455 ++++++++++++++++++++++++-------------
 drivers/net/e1000/e1000_osdep.h   |    9 +-
 drivers/net/e1000/e1000_param.c   |   19 +-
 drivers/net/ixgb/ixgb.h           |    1 +
 drivers/net/ixgb/ixgb_ethtool.c   |    1 +
 drivers/net/ixgb/ixgb_hw.c        |    3 +-
 drivers/net/ixgb/ixgb_main.c      |   60 +++++-
 11 files changed, 398 insertions(+), 221 deletions(-)


---
Auke Kok <auke-jan.h.kok@intel.com>
