From: Auke Kok <auke-jan.h.kok@intel.com>
Subject: [-MM GIT PULL] e1000: fixes, API rewrite, cleanups
Date: Thu, 29 Mar 2007 22:58:47 +0000 (UTC)
Message-ID: <20070329225815.C977F40951@ahkok-mobl.jf.intel.com>
Cc: jesse.brandeburg@intel.com, john.ronciak@intel.com,
	arjan@linux.intel.com, netdev@vger.kernel.org, jgarzik@pobox.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga01.intel.com ([192.55.52.88]:25750 "EHLO mga01.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S934201AbXC2W63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Mar 2007 18:58:29 -0400
Date: Thu Mar 29 15:50:55 PDT 2007
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Andrew,

Please consider pulling from my git tree:
    git-pull git://lost.foo-projects.org/~ahkok/git/netdev-2.6 mm

To get a copy of my current e1000 queue. This tree consists of a recent
'master' branch from linus, and the following patches:

1) 3 patches from jgarzik's e1000-fixes tree
2) 3 patches from jgarzik's upstream branch
3) the hardware initialization API rewrite (as a single commit) patch
     posted on netdev yesterday
4) 15 other fixes and cleanups currently in my e1000 queue


All patches from 3) onwards are also available to view over here:
    http://foo-projects.org/~sofar/patches-20070327/

Cheers,

Auke


---
commit a6f63e313c5a26340f52884c52492668a555c38b
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:59:38 2007 -0700

    e1000: Update version, typo fixes, date
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 18a6e4b... 3fc332a... M	drivers/net/e1000/e1000.h
:100644 100644 8a412c5... 05a0573... M	drivers/net/e1000/e1000_ethtool.c
:100644 100644 4d8443a... b157359... M	drivers/net/e1000/e1000_main.c
:100644 100644 3dc17ed... bd2d28a... M	drivers/net/e1000/e1000_osdep.h
:100644 100644 8bcb377... 95a39c0... M	drivers/net/e1000/e1000_param.c

commit 67de893160519308ca33248fb4b8e30f7cc1cf8f
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Thu Mar 29 14:59:26 2007 -0700

    e1000: insufficient use of DRV_LOAD bit causing firmware to take control
    
    The CTRL_EXT.DRV_LOAD bit was being cleared in the driver on every MAC
    reset (e.g. when the interface was down'ed) and not being properly set
    again (e.g. when the interface was re-up'ed). This caused AMT to think it
    was the sole owner of the h/w which consequently forced the PHY to 100Mbps
    since the f/w folks chose not to support 1000Mbps in order to not have to
    implement the Nineveh PHY powerdown workaround.
    
    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 e3b2e52... 4d8443a... M	drivers/net/e1000/e1000_main.c

commit 8d4d8333b64c6251ccb6eae56ea49efc6fc49f95
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:59:18 2007 -0700

    e1000: Free interrupts symmetrically with resume
    
    Free interrupts symmetrically with resume allocation to prevent
    pci save/restore state from possibly failing or warning.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 07f7e98... e3b2e52... M	drivers/net/e1000/e1000_main.c

commit 91f0e3ed1deef5183fc7a5ce9a424b01f79d4810
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Thu Mar 29 14:59:06 2007 -0700

    e1000: fix empty frame only containing a crc from being dumped
    
    A cornercase fragment could contain only the CRC but considered
    empty after crc stripping. Make sure we account for that.
    
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 69a204b... 07f7e98... M	drivers/net/e1000/e1000_main.c

commit 4d4b5ac4ab84de1f693c976764eb33b6aa1585c3
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Thu Mar 29 14:58:57 2007 -0700

    e1000: Fix some stats being collected on adapters that don't have them
    
    Several stats were being collected on ich8 that don't exist there.
    
    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 6037e78... 69a204b... M	drivers/net/e1000/e1000_main.c

commit 39db87a668ed8aac1dd75befd5f6f48dda0e3db7
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Thu Mar 29 14:58:38 2007 -0700

    e1000: fix two ich8 errata: tx timeouot factor and cable unplug issue
    
    for 10/100 modes, a simple incoming ping-flood could cause TX to delay
    long enough to scream 'TX hung' which was false. Extend the timeout
    factor for 10/100 speed.
    
    On a rare occasion, an ich8 device may lose link after a cable unplug
    event with the PHY. Downshifting the link prevents us from reading
    garbage from the PHY and makes sure that the PHY is accessible.
    
    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 90cffc4... 6037e78... M	drivers/net/e1000/e1000_main.c

commit 38fe2f8adb14761600d571f3ec269c55060e0da3
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:58:30 2007 -0700

    e1000: skip unneeded PHY reads in watchdog when link is OK
    
    Several PHY reads that are costly can be omitted if the link is up and
    netdev as well.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 4a322ae... 90cffc4... M	drivers/net/e1000/e1000_main.c

commit 95a01c8a78bc2e51dad8c0e667141023cb323e51
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Thu Mar 29 14:58:23 2007 -0700

    e1000: set timestamps before dma unmapping
    
    on the off chance that the check of buffer_info->dma returns true when
    buffer_info->time_stamp hasn't been filled in yet, reverse the order of
    populating these values.
    
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 21a626a... 4a322ae... M	drivers/net/e1000/e1000_main.c

commit dd673c5e9c15867fe1db032c6cf510924d5a5023
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Thu Mar 29 14:58:17 2007 -0700

    e1000: use skb_shinfo() instead of dereferencing protocol header
    
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 4e223b6... 21a626a... M	drivers/net/e1000/e1000_main.c

commit 040c42a5d37398625ca1cf6757520714983c439f
Author: Jesse Brandeburg <jesse.brandeburg@intel.com>
Date:   Thu Mar 29 14:58:08 2007 -0700

    e1000: fix panic on changing MTU under stress
    
    Change_mtu was changing rx_buffer_len while e1000_alloc_rx_buffer was
    still using it. The code was not waiting for RX activity to stop.
    Interrupts were reenabled when polling scheduled. Transmit was enabled
    even though the interface could be going down.
    
    Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 2641388... 4e223b6... M	drivers/net/e1000/e1000_main.c

commit 313340de0cb03b0cef8cd5b91cfb384792d15a3b
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:58:02 2007 -0700

    e1000: introduce watchdog task
    
    An SNMP program polling the interface using ethool multiple times per
    second exposed a design issue in the e1000 software_firmware semaphore.
    This semaphore can possibly be help for a relatively long time during which
    tx/rx continues normally, but other register reads/writes such as mac/phy
    settings or statistic reads are forced to wait.
    
    If a process in non-interrupt context is holding the semaphore while
    another one in interrupt context attempts to hold it, a deadlock occurs.
    This can be reproduced easily with a tight loop calling ethtool, because
    the watchdog code in e1000 currently runs entirely in interrupt context.
    
    The solution has multiple parts, but mostly introduces the watchdog timer
    task into the driver to assure that the semaphore is never held in
    interrupt context. This can be verified by placing a BUG_ON(in_interrupt())
    in that code.
    
    Aside from that, we need to assure that we are not re-scheduling the
    watchdog inadvertently while removing the device. Several state checks
    prevent those.
    
    Many thanks to Kenzo Iwami <k-iwami@cj.jp.nec.com> for persistently
    working with us in getting this fixed.
    
    Cc: Kenzo Iwami <k-iwami@cj.jp.nec.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 cb130b9... 18a6e4b... M	drivers/net/e1000/e1000.h
:100644 100644 bfc0144... 2641388... M	drivers/net/e1000/e1000_main.c

commit e25f5f64f5102bca1e5670e970aa5f0804724f4f
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:57:58 2007 -0700

    e1000: Add pci id of the quad-port version of the 82571
    
    Analogous to the quad-port copper (EB) version of the 82571, there is now
    a quad-port Fiber version of this card. There are no code changes involved,
    just the ID.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 11c1522... 8a412c5... M	drivers/net/e1000/e1000_ethtool.c
:100644 100644 8adf926... bfc0144... M	drivers/net/e1000/e1000_main.c

commit ee3acd41650c90a19de644c9900ec3795d6954ca
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:57:54 2007 -0700

    e1000: use pci id defines instead of hardcoded values in pci table
    
    To avoid confusion or omission, refer to the devices supported in
    the pci ID table by symbol name instead of hard-coded pci id number.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 eb459ac... 8adf926... M	drivers/net/e1000/e1000_main.c

commit 1443fc3063e0d86a231d60c00b64bb101b0943a9
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Thu Mar 29 14:57:48 2007 -0700

    e1000: cleanup header includes
    
    Adjust header includes to include stack includes etc. only in .c files
    where needed. The e1000 specific header files therefore lose most of the
    needed includes making internal relationships between the files a lot
    clearer.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 d701e29... cb130b9... M	drivers/net/e1000/e1000.h
:100644 100644 a09786c... 11c1522... M	drivers/net/e1000/e1000_ethtool.c
:100644 100644 031aa7b... eb459ac... M	drivers/net/e1000/e1000_main.c
:100644 100644 d486e63... 3dc17ed... M	drivers/net/e1000/e1000_osdep.h
:100644 100644 eaedf29... 8bcb377... M	drivers/net/e1000/e1000_param.c

commit 888ee934119afe3400ea237d73373139678f26e1
Author: Jeb Cramer <cramerj@intel.com>
Date:   Thu Mar 29 14:57:40 2007 -0700

    e1000: Convert integer types from uint32_t to u32 style
    
    Signed-off-by: Jeb Cramer <cramerj@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 e88a204... d701e29... M	drivers/net/e1000/e1000.h
:100644 100644 c26fdac... a09786c... M	drivers/net/e1000/e1000_ethtool.c
:100644 100644 13292a0... 031aa7b... M	drivers/net/e1000/e1000_main.c

commit 9b2248c4804333510c5e7b32196aee14e8e22cb0
Author: Jeb Cramer <cramerj@intel.com>
Date:   Wed Mar 28 15:05:53 2007 -0700

    e1000: rewrite hardware initialization layer code
    
    This series contains a major rewrite of the hardware initialization
    code that was duly needed due to the large amounts of hardware that
    e1000 supports, and the consequences of the convoluted init code that
    sets up the various parts.
    
    This code has been unwound completely and split up per chipset
    family. This introduces a clean and clear API for the hardware-specific
    register code.  Each chipset family code lives in a separate file and
    can (in the future) possibly be compiled optionally without affecting
    any of the other hardware.  PHY, NVM, manageability and MAC specific
    code has also been split up.
    
    Hardware assigns per-device specific function pointers to specific routines
    and the API provides a generic implementation for those e1000 adapters
    that don't any special code.
    
    Signed-off-by: Jeb Cramer <cramerj@intel.com>
    Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>

:100644 100644 4a6ab15... 1086807... M	drivers/net/e1000/Makefile
:100644 100644 dd4b728... e88a204... M	drivers/net/e1000/e1000.h
:000000 100644 0000000... ab9631c... A	drivers/net/e1000/e1000_80003es2lan.c
:000000 100644 0000000... feb258b... A	drivers/net/e1000/e1000_80003es2lan.h
:000000 100644 0000000... 41549b8... A	drivers/net/e1000/e1000_82540.c
:000000 100644 0000000... c1e74a3... A	drivers/net/e1000/e1000_82541.c
:000000 100644 0000000... b48d9cf... A	drivers/net/e1000/e1000_82541.h
:000000 100644 0000000... adca182... A	drivers/net/e1000/e1000_82542.c
:000000 100644 0000000... e61e34a... A	drivers/net/e1000/e1000_82543.c
:000000 100644 0000000... d5f0c5f... A	drivers/net/e1000/e1000_82543.h
:000000 100644 0000000... 32e11a5... A	drivers/net/e1000/e1000_82571.c
:000000 100644 0000000... 8aafd85... A	drivers/net/e1000/e1000_82571.h
:000000 100644 0000000... ea4dd64... A	drivers/net/e1000/e1000_api.c
:000000 100644 0000000... fdf4bb3... A	drivers/net/e1000/e1000_api.h
:000000 100644 0000000... dffe68d... A	drivers/net/e1000/e1000_defines.h
:100644 100644 2881da1... c26fdac... M	drivers/net/e1000/e1000_ethtool.c
:100644 000000 9be4469... 0000000... D	drivers/net/e1000/e1000_hw.c
:100644 100644 bd000b8... 49d8cd7... M	drivers/net/e1000/e1000_hw.h
:000000 100644 0000000... 4c6761d... A	drivers/net/e1000/e1000_ich8lan.c
:000000 100644 0000000... ee904ce... A	drivers/net/e1000/e1000_ich8lan.h
:000000 100644 0000000... 8359048... A	drivers/net/e1000/e1000_mac.c
:000000 100644 0000000... 47422f6... A	drivers/net/e1000/e1000_mac.h
:100644 100644 a561329... 13292a0... M	drivers/net/e1000/e1000_main.c
:000000 100644 0000000... 36bc082... A	drivers/net/e1000/e1000_manage.c
:000000 100644 0000000... 4ea91e0... A	drivers/net/e1000/e1000_manage.h
:000000 100644 0000000... 46544df... A	drivers/net/e1000/e1000_nvm.c
:000000 100644 0000000... 62261e3... A	drivers/net/e1000/e1000_nvm.h
:100644 100644 10af742... d486e63... M	drivers/net/e1000/e1000_osdep.h
:100644 100644 f8862e2... eaedf29... M	drivers/net/e1000/e1000_param.c
:000000 100644 0000000... 49d436d... A	drivers/net/e1000/e1000_phy.c
:000000 100644 0000000... ef8c31c... A	drivers/net/e1000/e1000_phy.h
:000000 100644 0000000... ce6175b... A	drivers/net/e1000/e1000_regs.h

commit a08b7851730ef1faf36f107b044a6094e7bfeee0
Author: Yan Burman <burman.yan@gmail.com>
Date:   Tue Mar 6 08:58:04 2007 -0800

    e1000: Use kcalloc()
    
    Replace kmalloc+memsetout the driver. Slightly modified by Auke Kok.
    
    Signed-off-by: Yan Burman <burman.yan@gmail.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 a094288... 2881da1... M	drivers/net/e1000/e1000_ethtool.c
:100644 100644 28dc690... a561329... M	drivers/net/e1000/e1000_main.c

commit af6417fadcb393c07d4a917e23b21098ec13f5eb
Author: Ahmed S. Darwish <darwish.07@gmail.com>
Date:   Tue Mar 6 08:58:02 2007 -0800

    e1000: Use ARRAY_SIZE macro when appropriate
    
    A patch to use ARRAY_SIZE macro already defined in kernel.h.
    
    Signed-off-by: Ahmed S. Darwish <darwish.07@gmail.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 6777887... a094288... M	drivers/net/e1000/e1000_ethtool.c

commit 6464482e36d38d279858d75f77a26cb868bb21c2
Author: Arjan van de Ven <arjan@linux.intel.com>
Date:   Tue Mar 6 02:41:48 2007 -0800

    user of the jiffies rounding code: e1000
    
    Use the round_jiffies() function in e1000.
    
    These timers all were of the "about once a second" or "about once every X
    seconds" variety and several showed up in the "what wakes the cpu up" profiles
    that the tickless patches provide.  Some timers are highly dynamic based on
    network load; but even on low activity systems they still show up so the
    rounding is done only in cases of low activity, allowing higher frequency
    timers in the high activity case.
    
    The various hardware watchdogs are an obvious case; they run every 2 seconds
    but aren't otherwise specific of exactly when they need to run.
    
    Signed-off-by: Arjan van de Ven <arjan@linux.intel.com>
    Acked-by: Auke Kok <auke-jan.h.kok@intel.com>
    Cc: Jeff Garzik <jeff@garzik.org>
    Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 3f170c8... 28dc690... M	drivers/net/e1000/e1000_main.c

commit 1f3aea119941a828d60a25ecf1d8d85cd441f11d
Author: Mark Huth <mhuth@mvista.com>
Date:   Tue Mar 6 08:57:26 2007 -0800

    e1000: FIX: Stop raw interrupts disabled nag from RT
    
    Current e1000_xmit_frame spews raw interrupt disabled nag messages when
    used with RT kernel patches.  This patch uses spin_trylock_irqsave,
    which allows RT patches to properly manage the irq semantics.
    
    Signed-off-by: Mark Huth <mhuth@mvista.com>
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 570a08b... 3f170c8... M	drivers/net/e1000/e1000_main.c

commit 1ee0898681f2ba60aea390ea974553edcc6e2183
Author: Bruce Allan <bruce.w.allan@intel.com>
Date:   Tue Mar 6 08:57:24 2007 -0800

    e1000: FIX: firmware handover bits
    
    Upon code inspection it was spotted that the firmware handover bit get/set
    mismatched, which may have resulted in management issues on PCI-E
    adapters. Setting them correctly may fix some management issues such
    as arp routing etc.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 3a685b7... 570a08b... M	drivers/net/e1000/e1000_main.c

commit 4ce07a7fb953794f80d85e01e0dce9ae463a26ad
Author: Auke Kok <auke-jan.h.kok@intel.com>
Date:   Tue Mar 6 08:57:21 2007 -0800

    e1000: FIX: be ready for incoming irq at pci_request_irq
    
    DEBUG_SHIRQ code exposed that e1000 was not ready for incoming interrupts
    after having called pci_request_irq. This obviously requires us to finish
    our software setup which assigns the irq handler before we request the
    irq.
    
    Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
    Signed-off-by: Jeff Garzik <jeff@garzik.org>

:100644 100644 1d08e93... 3a685b7... M	drivers/net/e1000/e1000_main.c

---
 drivers/net/e1000/Makefile            |   18 +-
 drivers/net/e1000/e1000.h             |  137 +-
 drivers/net/e1000/e1000_80003es2lan.c | 1377 +++++
 drivers/net/e1000/e1000_80003es2lan.h |   89 +
 drivers/net/e1000/e1000_82540.c       |  670 +++
 drivers/net/e1000/e1000_82541.c       | 1305 +++++
 drivers/net/e1000/e1000_82541.h       |   86 +
 drivers/net/e1000/e1000_82542.c       |  551 ++
 drivers/net/e1000/e1000_82543.c       | 1643 ++++++
 drivers/net/e1000/e1000_82543.h       |   45 +
 drivers/net/e1000/e1000_82571.c       | 1333 +++++
 drivers/net/e1000/e1000_82571.h       |   42 +
 drivers/net/e1000/e1000_api.c         | 1174 +++++
 drivers/net/e1000/e1000_api.h         |  160 +
 drivers/net/e1000/e1000_defines.h     | 1303 +++++
 drivers/net/e1000/e1000_ethtool.c     |  688 ++--
 drivers/net/e1000/e1000_hw.c          | 9038 ---------------------------------
 drivers/net/e1000/e1000_hw.h          | 3857 +++------------
 drivers/net/e1000/e1000_ich8lan.c     | 2443 +++++++++
 drivers/net/e1000/e1000_ich8lan.h     |  110 +
 drivers/net/e1000/e1000_mac.c         | 1939 +++++++
 drivers/net/e1000/e1000_mac.h         |   84 +
 drivers/net/e1000/e1000_main.c        | 1695 ++++---
 drivers/net/e1000/e1000_manage.c      |  384 ++
 drivers/net/e1000/e1000_manage.h      |   83 +
 drivers/net/e1000/e1000_nvm.c         |  859 ++++
 drivers/net/e1000/e1000_nvm.h         |   60 +
 drivers/net/e1000/e1000_osdep.h       |   59 +-
 drivers/net/e1000/e1000_param.c       |  103 +-
 drivers/net/e1000/e1000_phy.c         | 1933 +++++++
 drivers/net/e1000/e1000_phy.h         |  159 +
 drivers/net/e1000/e1000_regs.h        |  261 +
 32 files changed, 20118 insertions(+), 13570 deletions(-)
 create mode 100644 drivers/net/e1000/e1000_80003es2lan.c
 create mode 100644 drivers/net/e1000/e1000_80003es2lan.h
 create mode 100644 drivers/net/e1000/e1000_82540.c
 create mode 100644 drivers/net/e1000/e1000_82541.c
 create mode 100644 drivers/net/e1000/e1000_82541.h
 create mode 100644 drivers/net/e1000/e1000_82542.c
 create mode 100644 drivers/net/e1000/e1000_82543.c
 create mode 100644 drivers/net/e1000/e1000_82543.h
 create mode 100644 drivers/net/e1000/e1000_82571.c
 create mode 100644 drivers/net/e1000/e1000_82571.h
 create mode 100644 drivers/net/e1000/e1000_api.c
 create mode 100644 drivers/net/e1000/e1000_api.h
 create mode 100644 drivers/net/e1000/e1000_defines.h
 delete mode 100644 drivers/net/e1000/e1000_hw.c
 create mode 100644 drivers/net/e1000/e1000_ich8lan.c
 create mode 100644 drivers/net/e1000/e1000_ich8lan.h
 create mode 100644 drivers/net/e1000/e1000_mac.c
 create mode 100644 drivers/net/e1000/e1000_mac.h
 create mode 100644 drivers/net/e1000/e1000_manage.c
 create mode 100644 drivers/net/e1000/e1000_manage.h
 create mode 100644 drivers/net/e1000/e1000_nvm.c
 create mode 100644 drivers/net/e1000/e1000_nvm.h
 create mode 100644 drivers/net/e1000/e1000_phy.c
 create mode 100644 drivers/net/e1000/e1000_phy.h
 create mode 100644 drivers/net/e1000/e1000_regs.h
