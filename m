From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [GIT PATCH] e100, e1000, ixgb updates for #upstream
Date: Wed, 27 Sep 2006 13:31:18 -0700
Message-ID: <451ADF96.7030407@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	"Ronciak, John" <john.ronciak@intel.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga03.intel.com ([143.182.124.21]:32152 "EHLO mga03.intel.com")
	by vger.kernel.org with ESMTP id S1030781AbWI0UdD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2006 16:33:03 -0400
To: Jeff Garzik <jgarzik@pobox.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Hi,

Here are updated updates targeted to branch #upstream-fixes from netdev-2.6, including
fixes to e100, e1000 and ixgb.

Changes from last weeks submission:
1) removed taint flag setting when eeprom csum fails (e100)
2) added CONFIG_PM wrappers around .suspend mthod (e1000)
3) added comments and (1 << n) for hardware bit spanking function (e1000)
4) keep flow control enum (e1000)
5) clean up ethtool stats as much as possible to use real HW counters (e1000)
6) add patch from linas Vepstas (e1000, PCI_D3 etc state symbols)
7) add patch from Vasily Averin (e1000, memleak in e1000_set_ringparam)


Please pull from:

git pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 upstream

these patches are against
   netdev-2.6#upstream 8aca23103c2ed2cf158adbe92f4f17ee69463d1a

Cheers,

Auke


---
  drivers/net/e100.c                |   82 +-
  drivers/net/e1000/LICENSE         |  339 -----------
  drivers/net/e1000/Makefile        |   35 -
  drivers/net/e1000/e1000.h         |   59 --
  drivers/net/e1000/e1000_ethtool.c |  150 ++---
  drivers/net/e1000/e1000_hw.c      | 1076 +++++++++++++++++---------------------
  drivers/net/e1000/e1000_hw.h      |   86 +--
  drivers/net/e1000/e1000_main.c    |  277 ++++++---
  drivers/net/e1000/e1000_osdep.h   |   35 -
  drivers/net/e1000/e1000_param.c   |   47 -
  drivers/net/ixgb/Makefile         |   38 -
  drivers/net/ixgb/ixgb.h           |   38 -
  drivers/net/ixgb/ixgb_ee.c        |   36 -
  drivers/net/ixgb/ixgb_ee.h        |   36 -
  drivers/net/ixgb/ixgb_ethtool.c   |   36 -
  drivers/net/ixgb/ixgb_hw.c        |   36 -
  drivers/net/ixgb/ixgb_hw.h        |   36 -
  drivers/net/ixgb/ixgb_ids.h       |   36 -
  drivers/net/ixgb/ixgb_main.c      |   46 -
  drivers/net/ixgb/ixgb_osdep.h     |   36 -
  drivers/net/ixgb/ixgb_param.c     |   36 -
  21 files changed, 1108 insertions(+), 1488 deletions(-)

---

Summary:

---


Auke Kok <auke-jan.h.kok@intel.com>:
      e100, e1000, ixgb: update copyright header and remove LICENSE
      e100, e1000, ixgb: Fix an impossible memory overwrite bug
      e1000: keep .suspend and .resume driver methods in CONFIG_PM
      e100: rework WoL and shutdown handling
      e1000: driver state fixes (race fix)
      ixgb: convert to netdev_priv(netdev)
      e100, e1000, ixgb: increment version numbers

Bruce Allan <bruce.w.allan@intel.com>:
      e1000: Jumbo frames fixes for 82573
      e1000: handle manageability for pci-e adapters at PHY powerdown
      e1000: don't strip vlan ID if 8021q claims it

Jeff Kirsher <jeffrey.t.kirsher@intel.com>:
      e1000: rename flow control symbols
      e1000: add enums for several link properties
      e1000: allow ethtool to pass arbitrary speed advertisment
      e1000: Fix MANC detection for PCIE adapters
      e1000: gather hardware bit tweaks.
      e1000: add PCI-E capability detection code
      e1000: reduce RAR entries available for ICH8
      e1000: rework polarity, NVM, eeprom code and fixes.

Jesse Brandeburg <jesse.brandeburg@intel.com>:
      e100: Add debugging code for cb cleaning.
      e1000: Maybe stop TX if not enough free descriptors
      ixgb: combine more rx descriptors to improve performance

Linas Vepstas <linas@austin.ibm.com>:
      e1000: Janitor: Use #defined values for literals

Mitch Williams <mitch.a.williams@intel.com>:
      e1000: add multicast stats counters

Nicholas Nunley <nicholas.d.nunley@intel.com>:
      e1000: remove unused code and make symbols static

Vasily Averin <vvs@sw.ru>:
      e1000: possible memory leak in e1000_set_ringparam
