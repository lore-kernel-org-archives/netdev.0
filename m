From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] 2.6.x net driver updates
Date: Wed, 30 Jun 2004 23:54:02 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040701035402.GA25546@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



This is what I just sent to Andrew and Linus.

BK users may do a

	bk pull bk://gkernel.bkbits.net/net-drivers-2.6

This will update the following files:

 drivers/net/arm/smc91x.c                      | 2171 -------------------------
 drivers/net/arm/smc91x.h                      |  829 ---------
 drivers/net/3c59x.c                           |    6 
 drivers/net/Kconfig                           |   25 
 drivers/net/Makefile                          |    2 
 drivers/net/acenic.c                          |   12 
 drivers/net/arm/Kconfig                       |   18 
 drivers/net/arm/Makefile                      |    1 
 drivers/net/eepro100.c                        |    6 
 drivers/net/epic100.c                         |    6 
 drivers/net/fec_8xx/Kconfig                   |   14 
 drivers/net/fec_8xx/Makefile                  |   12 
 drivers/net/fec_8xx/fec_8xx-netta.c           |  153 +
 drivers/net/fec_8xx/fec_8xx.h                 |  218 ++
 drivers/net/fec_8xx/fec_main.c                | 1275 +++++++++++++++
 drivers/net/fec_8xx/fec_mii.c                 |  380 ++++
 drivers/net/ixgb/ixgb.h                       |    2 
 drivers/net/natsemi.c                         |    6 
 drivers/net/pcmcia/3c574_cs.c                 |   11 
 drivers/net/pcmcia/3c589_cs.c                 |    9 
 drivers/net/pcmcia/axnet_cs.c                 |    9 
 drivers/net/pcmcia/com20020_cs.c              |   32 
 drivers/net/pcmcia/fmvj18x_cs.c               |    9 
 drivers/net/pcmcia/ibmtr_cs.c                 |    1 
 drivers/net/pcmcia/nmclan_cs.c                |    9 
 drivers/net/pcmcia/pcnet_cs.c                 |    9 
 drivers/net/pcmcia/smc91c92_cs.c              |    9 
 drivers/net/pcmcia/xirc2ps_cs.c               |    9 
 drivers/net/pcnet32.c                         |   61 
 drivers/net/sb1250-mac.c                      |    6 
 drivers/net/sk98lin/h/skdrv1st.h              |    6 
 drivers/net/skfp/fplustm.c                    |   28 
 drivers/net/skfp/h/cmtdef.h                   |    4 
 drivers/net/skfp/h/targetos.h                 |    2 
 drivers/net/skfp/skfddi.c                     |    5 
 drivers/net/skfp/smt.c                        |   86 -
 drivers/net/smc91x.c                          | 2173 ++++++++++++++++++++++++++
 drivers/net/smc91x.h                          |  866 ++++++++++
 drivers/net/sundance.c                        |    9 
 drivers/net/tulip/winbond-840.c               |    9 
 drivers/net/typhoon.c                         |    6 
 drivers/net/via-rhine.c                       |    6 
 drivers/net/wan/sbni.h                        |    2 
 drivers/net/wireless/prism54/isl_ioctl.c      |    4 
 drivers/net/wireless/prism54/islpci_dev.c     |    7 
 drivers/net/wireless/prism54/islpci_dev.h     |    2 
 drivers/net/wireless/prism54/islpci_eth.c     |    8 
 drivers/net/wireless/prism54/islpci_hotplug.c |  124 +
 drivers/net/wireless/prism54/islpci_mgt.h     |    3 
 drivers/net/wireless/prism54/oid_mgt.c        |    4 
 drivers/net/yellowfin.c                       |    8 
 51 files changed, 5374 insertions(+), 3298 deletions(-)

through these ChangeSets:

<jgarzik@pobox.com> (04/06/30 1.1805)
   [netdrvr] add fec_8xx to Makefile

<shemminger@osdl.org> (04/06/30 1.1804)
   [PATCH] skfddi - cleanup local and dead functions
   
   Cleanup the SK Fddi driver a little more.  Mark some functions as static,
   and eliminate (or comment out) some that are defined but never used.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

<shemminger@osdl.org> (04/06/30 1.1803)
   [PATCH] skfddi - fix warning
   
   The conversion to ANSI, caused a warning because the mulitcast code needs
   a cast.  dmi->dmi_addr is a u8 array, and fddi_addr is just a wrapper around a u8 array.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

<panto@intracom.gr> (04/06/30 1.1802)
   [PATCH] add new fec_8xx network driver

<dale@farnsworth.org> (04/06/30 1.1801)
   [PATCH] Patch 2/2 enable smc91x enet driver for use by PPC
   
   Hi,
   
   Patch 2 of 2 to enable the smc91x driver to be used by the IBM Redwood5
   and Redwood6 boards.
   
   Enable smc91x driver to support IBM Redwood5 and Redwood6 boards
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<dale@farnsworth.org> (04/06/30 1.1800)
   [PATCH] Patch 1/2 enable smc91x enet driver for use by PPC
   
   Hi,
   
   Patch 1 of 2 to enable the smc91x driver to be used by the IBM Redwood5
   and Redwood6 boards.
   
   Move drivers/net/arm/smc91x.[ch] to drivers/net
   
   Signed-off-by: Dale Farnsworth <dale@farnsworth.org>

<rmk+lkml@arm.linux.org.uk> (04/06/30 1.1799)
   [PATCH] PCMCIA net device unplugging ordering fix
   
   This is a rather old patch which re-orders the teardown of PCMCIA
   network devices.  Current device drivers remove the IO mappings,
   interrupts, and free any PCMCIA windows before they unregister
   themselves from the network layer.
   
   This patch ensures that we first unregister from the network layer
   before performing any teardown of resources or windows.
   
   Note: the only card which has been tested in this patch is pcnet_cs.

<shemminger@osdl.org> (04/06/30 1.1798)
   [PATCH] get rid of __OPTIMIZE__ requirement in net drivers
   
   Several network drivers have checks that they are only built with -O.
   This breaks checking with sparse and other tools, and seems like a holdover from
   when drivers were built out of tree and the kernel build system was less stable.
   This patch gets rid of these.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

<shemminger@osdl.org> (04/06/30 1.1797)
   [PATCH] [sparse] get rid of warnings about #if DEBUG
   
   Several drivers use '#if DEBUG' which is a warning under the sparse checker.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

<shemminger@osdl.org> (04/06/30 1.1796)
   [PATCH] (2/3) skfp -- sparse __user annotation
   
   Add __user annotation to the device specific ioctl.

<shemminger@osdl.org> (04/06/30 1.1795)
   [PATCH] (1/3) skfp - cleanup is_XXX functions
   
   This started out from sparse warnings about calling with fddi_broadcast
   that is declared const.  This fixes that and gets rid of some of the namespace
   pollution of this driver by moving the predicate function is_individual, is_broadcast, ...
   as inline's in the one file that uses them.
   
   Signed-off-by: Stephen Hemminger <shemminger@osdl.org>

<akpm@osdl.org> (04/06/30 1.1794)
   [PATCH] net/ne2.c needs MCA_LEGACY
   
   From: "Luiz Fernando N. Capitulino" <lcapitulino@prefeitura.sp.gov.br>
   
   drivers/net/ne2.c does not compile without CONFIG_MCA_LEGACY set.
   
   As CONFIG_MCA_LEGACY depends on CONFIG_MCA, we can use only
   CONFIG_MCA_LEGACY, insteed of "MCA && MCA_LEGACY".
   
   Signed-off-by: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<akpm@osdl.org> (04/06/30 1.1793)
   [PATCH] net/at1700.c depends on MCA_LEGACY
   
   From: "Luiz Fernando N. Capitulino" <lcapitulino@prefeitura.sp.gov.br>
   
   drivers/net/at1700.c does not compile without CONFIG_MCA_LEGACY set.
   
   As CONFIG_MCA_LEGACY depends on CONFIG_MCA, we can use only
   CONFIG_MCA_LEGACY, insteed of "MCA && MCA_LEGACY".
   
   Signed-off-by: Luiz Capitulino <lcapitulino@prefeitura.sp.gov.br>
   Signed-off-by: Andrew Morton <akpm@osdl.org>

<brazilnut@us.ibm.com> (04/06/30 1.1792)
   [PATCH] pcnet32: change to use module_param
   
   Change the pcnet32 driver to use module_param and module_param_array.

<brazilnut@us.ibm.com> (04/06/30 1.1791)
   [PATCH] pcnet32:  correctly program bcr32.
   
   The pcnet32 driver was not correctly enabling MII autonegotiation after
   booting when ppc firmware forced the speed/duplex mode of the chip.
   After several conversations with AMD this patch corrects the problem.
   
   I have tested this on hardware I have available (ia32 and ppc64) but I
   would like wider audience testing of this patch.
   
   Signed-off-by: Don Fry <brazilnut@us.ibm.com>

<brazilnut@us.ibm.com> (04/06/30 1.1790)
   [PATCH] pcnet32: Add HomePNA parameter for 79C978.
   
   This patch adds a module parameter to select HomePNA mode of operation for
   the 79C978 version of the pcnet32.  Tested ia32 and ppc64.
   
   signed-off-by: Patrick Simmons <psimmons@flash.net>
   signed-off-by: Don Fry <brazilnut@us.ibm.com>

<brazilnut@us.ibm.com> (04/06/30 1.1789)
   [PATCH] pcnet32: acknowledge all interrupts early.
   
   A recent change I made broke pcnet32 in a way that allowed real hardware
   to work, but broke VMWare.  This patch acknowledges all interrupts early
   in the pcnet32_interrupt while loop.  Without this patch on real hardware
   the first transmit operation would clear the 'init' interrupt, but in
   VMWare it would rain interrupts.  Keith Moore did more testing for me
   on VMWare and I did a better job testing on hardware.  Petr Vandrovec
   correctly pointed out the source of the problem on lkml.
   
   This patch is not needed for 2.4.27-rc1 unless my patch labeled
   "pcnet32: recover after rx hang" is applied (which it has not).
   
   signed-off-by: Don Fry <brazilnut@us.ibm.com>

<margitsw@t-online.de> (04/06/30 1.1788)
   [PATCH] prism54 use set_pci_mwi()
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Use set_pci_mwi()

<margitsw@t-online.de> (04/06/30 1.1787)
   [PATCH] prism54 remove prog reg poke
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Don't poke around in the timeout registers

<margitsw@t-online.de> (04/06/30 1.1786)
   [PATCH] prism54 device list cleanup
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Clean up the device table

<margitsw@t-online.de> (04/06/30 1.1785)
   [PATCH] prism54 fix unlikely
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Fix a thinko by me

<margitsw@t-online.de> (04/06/30 1.1784)
   [PATCH] prism54 missing error check
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Missing error check after dev_alloc_skb

<margitsw@t-online.de> (04/06/30 1.1783)
   [PATCH] prism54 cleanup functions
   
   2004-06-28 Margit Schubert-While <margitsw@t-online.de>
   
   * Clean up function definitions (missing static, extraneous inline)
