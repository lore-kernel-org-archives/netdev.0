From: Jeff Garzik <jgarzik@pobox.com>
Subject: [bk patches] 2.6.x net driver updates
Date: Thu, 11 Sep 2003 15:54:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030911195402.GA29213@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.5

The patch may be found at

ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.6/2.6.0-test5-bk2-netdrvr1.patch.bz2

This will update the following files:

 Documentation/networking/ifenslave.c |    1 
 drivers/net/Space.c                  |    5 
 drivers/net/bonding/bond_3ad.c       |   12 
 drivers/net/bonding/bond_3ad.h       |    2 
 drivers/net/bonding/bond_alb.c       |   17 
 drivers/net/bonding/bond_main.c      |  450 ++++---
 drivers/net/bonding/bonding.h        |    2 
 drivers/net/e1000/e1000.h            |    9 
 drivers/net/e1000/e1000_ethtool.c    |   84 +
 drivers/net/e1000/e1000_hw.c         | 2034 +++++++++++++++++++++--------------
 drivers/net/e1000/e1000_hw.h         |  405 ++++--
 drivers/net/e1000/e1000_main.c       |  204 ++-
 drivers/net/e1000/e1000_osdep.h      |    3 
 drivers/net/e1000/e1000_param.c      |   27 
 drivers/net/slip.c                   |    3 
 drivers/net/tokenring/olympic.c      |   37 
 drivers/net/wan/cosa.c               |   50 
 drivers/net/wan/cosa.h               |   12 
 drivers/net/wan/dlci.c               |  183 +--
 drivers/net/wan/sdla.c               |   92 -
 include/linux/if_frad.h              |    3 
 21 files changed, 2201 insertions(+), 1434 deletions(-)

through these ChangeSets:

<romieu@fr.zoreil.com> (03/09/11 1.1312)
   [PATCH] (1/4) sdla - move out of Space.c
   
   Apply on top of 2.6.0-test5-bk1 + Stephen sdla patches. Compiles fine.
   
   
   free_netdev() patrol.
   
   
    drivers/net/wan/sdla.c |    2 +-
    1 files changed, 1 insertion(+), 1 deletion(-)

<shemminger@osdl.org> (03/09/11 1.1311)
   [PATCH] (5/4) dlci netdevice event handling
   
   One more patch, found this in testing
    -- need to delete device from list when unregistered
   because of callback.

<shemminger@osdl.org> (03/09/11 1.1310)
   [PATCH] (4/4) dlci netdevice event handling
   
   Since dlci device is a pseudo device built on top of sdla, change it to
   handle unregister events and delete itself.

<shemminger@osdl.org> (03/09/11 1.1309)
   [PATCH] (3/4) dlci locking and registration changes
   
   Change the locking for the dlci device list and registration.
   - use RTNL instead of a private lock (needed for net notifier in next patch).
   - reorder the checks in the dlci_add to avoid complicated unwinds
   - use dev->destructor to free
   - hold RTNL around deassoc to protect callback from races

<shemminger@osdl.org> (03/09/11 1.1308)
   [PATCH] (2/4) get rid of register_frad
   
   The sdla and dlci drivers have a callback interface which only stores a name
   in a table, but doesn't do anything useful. Looks like an interface which has
   lost it's usefulness and can be safely removed.
   
   Tested on 2.6.0-test5 by exercising the higher layer (dlci) without real hardware.

<shemminger@osdl.org> (03/09/11 1.1307)
   [PATCH] (1/4) sdla - move out of Space.c
   
   Patch against 2.60-test5 to move sdla driver out of Space.c for initialization
   in non-module case.  Since this driver doesn't come up until the device has
   been configured with an ioctl (set_config); there is no way it can have
   startup order problems.

<shemminger@osdl.org> (03/09/11 1.1306)
   [PATCH] fix build of cosa
   
   The cosa driver definition of ioctl's either conflicts or was not picked
   up in the last round of _IOR redefinition (on 2.6.0-test5).
   
   The following makes it build, have no idea if it still works
   on real hardware.

<felipewd@terra.com.br> (03/09/11 1.1305)
   [PATCH] slip.c: current state cleanup

<rddunlap@osdl.org> (03/09/11 1.1304)
   [PATCH] tr/olympic probe: remove #warning, improve error handling
   
   This patch to 2.6.0-test5 removes the #warning in tokenring/olympic.c
   and improves error handling in the probe function.

<scott.feldman@intel.com> (03/09/11 1.1303)
   [e1000] misc whitespace cleanup, changelog
   
   * misc whitespace cleanup, changelog

<scott.feldman@intel.com> (03/09/11 1.1302)
   [e1000] Add PHY master/slave #define override
   
   * Add PHY master/slave #define override to address link issues
     with 82541/7 (rev2) against some low-end switches.  Forcing
     master will improve the time-to-link against these switches.

<scott.feldman@intel.com> (03/09/11 1.1301)
   [e1000] move static to table from .h to .c
   
   * Move static table from hw.h to hw.c to avoid creating a copy
     of table everytime hw.h is included.in .c.

<scott.feldman@intel.com> (03/09/11 1.1300)
   [e1000] cleanup error return codes
   
   * clean up error return code propagation and eliminate redundant
     DEBUGOUT statements.

<scott.feldman@intel.com> (03/09/11 1.1299)
   [e1000] make function our of setting media type
   
   * Consolidate code and make function out of setting media type.

<scott.feldman@intel.com> (03/09/11 1.1298)
   [e1000] add ethtool flow control support
   
   * Add ethtool flow control support

<scott.feldman@intel.com> (03/09/11 1.1297)
   [e1000] read correct bit from EEPROM for getting WoL settings
   
   * Bug fix: read the correct bit from the EEPROM that controls the
     initial setting for WoL after a reset.

<scott.feldman@intel.com> (03/09/11 1.1296)
   [e1000] Turn off ASF support on Fiber nics
   
   * Turn off ASF support on fiber nics.  Wasn't tested and isn't
     known to work, so disable before someone hurts themselves.

<scott.feldman@intel.com> (03/09/11 1.1295)
   [e1000] 82544 PCI-X hang fix + TSO updates
   
   * Bug fix: 82544 hang with PCI-X: if outgoing Tx buffers terminate
     within evenly-aligned dwords, and the device is sharing the bus
     segment with another PCI-X device, 82544 can hang the bus on a
     split-completion transaction.  Fix is to split buffer into two
     buffers with the first one not terminating within evenly-aligned
     dword address, and the second one being 4-bytes, which goes as a
     non-split-conpletion PCI-X transaction.
   * 8254x controllers that support TSO do an internal calculation to
     make sure there is enough FIFO space to handle the overhead
     of each TSO segment before DMA'ing TSO data from host memory.  The
     internal calculation is dependent on the mss of the TSO (defines
     the number of segments), but the reserved space is a constant, so
     we need to adjust the maximum size of each buffer queued to the
     hardware to hold the equation and not overrun the FIFO.  This is
     per TSO because the mss can change from one send to the next.

<scott.feldman@intel.com> (03/09/11 1.1294)
   [e1000] new 82541/5/6/7 hardware support
   
   * Added 82545 (rev3), 82546 (rev3), and 82541/7 (rev2) support
   	- new device IDs
   	- internal SERDES support for 82545/6 (rev3)
   	- don't apply MMRBC workaround for 82545/6 (rev3)
   	- don't use IO mapping for reset for 82545/6 (rev3)

<amir.noam@intel.com> (03/09/11 1.1293)
   [bonding 2.6] misc fixes: missing include, typos, comments

<amir.noam@intel.com> (03/09/11 1.1292)
   [bonding 2.6] make each bond device use its own /proc entry

<amir.noam@intel.com> (03/09/11 1.1291)
   [bonding 2.6] fix error handling in init code

<amir.noam@intel.com> (03/09/11 1.1290)
   [bonding 2.6] embed stats struct inside bonding private struct

<amir.noam@intel.com> (03/09/11 1.1289)
   [bonding 2.6] fix OOPS in bonding driver, when removing primary

<amir.noam@intel.com> (03/09/11 1.1288)
   [bonding 2.6] fix change active command

<amir.noam@intel.com> (03/09/11 1.1287)
   [bonding 2.6] fix kernel panic when optional feature used

<amir.noam@intel.com> (03/09/11 1.1286)
   [bonding 2.6] fix ARP monitoring bug

<amir.noam@intel.com> (03/09/11 1.1285)
   [bonding 2.6] fix load balance problem with high UDP Tx stress

<amir.noam@intel.com> (03/09/11 1.1284)
   [bonding 2.6] fix 802.3ad long fail over with high UDP Tx stress
