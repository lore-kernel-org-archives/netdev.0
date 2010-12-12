From: Joe Perches <joe@perches.com>
Subject: [RFC PATCH net-next 0/6] Start moving ethernet drivers to new directory
Date: Sun, 12 Dec 2010 04:03:21 -0800
Message-ID: <cover.1292154142.git.joe@perches.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.perches.com ([173.55.12.10]:2503 "EHLO mail.perches.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752254Ab0LLMDc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 12 Dec 2010 07:03:32 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

As discussed a few times, here's a start at moving various files
around in drivers/net to a new drivers/net/ethernet directory.

The general idea is to move one at a time compilation units
associated to the various subsystems in drivers/net, updating
the Kconfig and Makefile files. 

I think this is a form that doesn't break the build, is reviewable
and acceptable and makes the top level drivers/net directory much
cleaner.

The biggest downsides of this move style are:

o high number of trivial commits so:
o serialization: it's best done by one person because the likelihood
  of commit clash will be also be high.
o the order the entries in Kconfig are changed, so the order of entries
  in menuconfig/xconfig is also changed.

An alternative to the high commit count is to collect many of these patches
together into a single commit.

If this approach is acceptable, I'll do all the unmaintained ethernet
subsystems in drivers/net in this style, followed by adding separate
subdirectories for 3com and 8390, moving tulip, then onto the various
vendor directories as appropriate.

Moving bonding, ppp, and such to different directories will be done
separately.

David, the Sun GEM and Cassini files are currently selected under the
10/100 menu.  Shouldn't these be presented under the 1000Mb menu?
I didn't move them to that menu so all current configs should work,
but it'd be logically sensible to move the selection for these subsystems
to the 1000 menu though maybe that's not practical.

Comments?

Joe Perches (6):
  drivers/net: Add directory ethernet
  ethernet: Move ethoc.c
  ethernet: Move dnet.[ch]
  ethernet: Move Sun Happymeal sunhme.[ch]
  ethernet: Move Sun GEM sungem*.[ch]
  ethernet: Move Sun Cassini cassini.[ch]

 drivers/net/Kconfig                     |   56 +++---------------------------
 drivers/net/Makefile                    |    7 +---
 drivers/net/ethernet/Kconfig.10-100     |   53 +++++++++++++++++++++++++++++
 drivers/net/ethernet/Kconfig.1000       |    3 ++
 drivers/net/ethernet/Kconfig.10000      |    3 ++
 drivers/net/ethernet/Makefile           |    9 +++++
 drivers/net/{ => ethernet}/cassini.c    |    0
 drivers/net/{ => ethernet}/cassini.h    |    0
 drivers/net/{ => ethernet}/dnet.c       |    0
 drivers/net/{ => ethernet}/dnet.h       |    0
 drivers/net/{ => ethernet}/ethoc.c      |    0
 drivers/net/{ => ethernet}/sungem.c     |    0
 drivers/net/{ => ethernet}/sungem.h     |    0
 drivers/net/{ => ethernet}/sungem_phy.c |    0
 drivers/net/{ => ethernet}/sungem_phy.h |    0
 drivers/net/{ => ethernet}/sunhme.c     |    0
 drivers/net/{ => ethernet}/sunhme.h     |    0
 17 files changed, 76 insertions(+), 55 deletions(-)
 create mode 100644 drivers/net/ethernet/Kconfig.10-100
 create mode 100644 drivers/net/ethernet/Kconfig.1000
 create mode 100644 drivers/net/ethernet/Kconfig.10000
 create mode 100644 drivers/net/ethernet/Makefile
 rename drivers/net/{ => ethernet}/cassini.c (100%)
 rename drivers/net/{ => ethernet}/cassini.h (100%)
 rename drivers/net/{ => ethernet}/dnet.c (100%)
 rename drivers/net/{ => ethernet}/dnet.h (100%)
 rename drivers/net/{ => ethernet}/ethoc.c (100%)
 rename drivers/net/{ => ethernet}/sungem.c (100%)
 rename drivers/net/{ => ethernet}/sungem.h (100%)
 rename drivers/net/{ => ethernet}/sungem_phy.c (100%)
 rename drivers/net/{ => ethernet}/sungem_phy.h (100%)
 rename drivers/net/{ => ethernet}/sunhme.c (100%)
 rename drivers/net/{ => ethernet}/sunhme.h (100%)

-- 
1.7.3.3.398.g0b0cd.dirty

