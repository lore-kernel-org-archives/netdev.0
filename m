From: Jeff Garzik <jgarzik@pobox.com>
Subject: [BK PATCHES] more net driver merges
Date: Thu, 10 Jul 2003 19:55:18 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030710235518.GA16507@gtf.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-bounce@oss.sgi.com>
To: torvalds@osdl.org, linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Content-Disposition: inline
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


Linus, please do a

	bk pull bk://kernel.bkbits.net/jgarzik/net-drivers-2.5

Others may download

ftp://ftp.kernel.org/pub/linux/kernel/people/jgarzik/patchkits/2.5/2.5.75-netdrvr1.patch.bz2

This will update the following files:

 drivers/net/appletalk/cops.c     |    5 -
 drivers/net/appletalk/ltpc.c     |    5 -
 drivers/net/declance.c           |    2 
 drivers/net/dgrs.c               |   27 +++----
 drivers/net/e100/e100_main.c     |   32 +++-----
 drivers/net/e100/e100_phy.c      |    2 
 drivers/net/hamradio/mkiss.c     |  141 +++++++--------------------------------
 drivers/net/hamradio/mkiss.h     |    2 
 drivers/net/pcmcia/3c574_cs.c    |    2 
 drivers/net/pcmcia/3c589_cs.c    |    2 
 drivers/net/pcmcia/smc91c92_cs.c |    2 
 drivers/net/plip.c               |   96 ++++++++++++--------------
 drivers/net/sb1250-mac.c         |    2 
 drivers/net/sk_mca.c             |    2 
 drivers/net/sundance.c           |   10 ++
 drivers/net/tg3.c                |    5 -
 drivers/net/tokenring/3c359.c    |    2 
 drivers/net/tokenring/proteon.c  |    1 
 drivers/net/tokenring/skisa.c    |    1 
 drivers/net/via-rhine.c          |    2 
 drivers/net/wireless/atmel_cs.c  |   11 +--
 drivers/net/wireless/wavelan.c   |    6 +
 22 files changed, 131 insertions(+), 229 deletions(-)

through these ChangeSets:

<jgarzik@redhat.com> (03/07/10 1.1400)
   [netdrvr atmel_cs] kill compiler warning (jumping to "empty" label)

<jgarzik@redhat.com> (03/07/10 1.1399)
   [netdrvr wavelan] remove check_region usage

<jgarzik@redhat.com> (03/07/10 1.1398)
   [netdrvr] fix compiler warnings in 3c359, proteon, skisa
   tokenring drivers.

<jgarzik@redhat.com> (03/07/10 1.1397)
   [netdrvr tg3] more ULL suffixes to make gcc 3.3 happy

<shemminger@osdl.org> (03/07/10 1.1396)
   [netdrvr dgrs] convert to using alloc_etherdev

<daniel.ritz@gmx.ch> (03/07/10 1.1395)
   [PATCH] net/pcmcia fix fast_poll timers (HZ > 100)
   
   i think we want fast_poll to behave the same with HZ=100 and HZ=1000

<daniel.ritz@gmx.ch> (03/07/10 1.1394)
   [PATCH] more net driver timer fixes
   
   following patch fixes some bogus additions to jiffies (w/o HZ beeing involved)
   - appletalk/cops.c
   - appletalk/ltpc.c
   - declance.c
   - sb1250-mac.c
   - sk_mca.c
   - via-rhine.c
   against 2.5.73-bk

<ralf@linux-mips.org> (03/07/10 1.1393)
   [PATCH] mkiss
   
   Below patch cleans the mkiss driver.  After the previous cleanup in
   2.4.0-prerelease various code had become unreachable because nothing
   was ever setting MKISS_DRIVER_MAGIC.  This fixes fixes an oops - the
   mkiss pointer was potencially NULL.  And it also removes the
   MOD_{INC,DEC}_USE_COUNT calls.
   
   Alan, lemme know if you want me to cook a 2.4 patch also.
   
   Patch from Jeroen Vreeken PE1RXQ.
   
   Ralf

<shemminger@osdl.org> (03/07/10 1.1392)
   [PATCH] convert plip to alloc_netdev
   
   This converts the parallel network driver to use alloc_netdev instead
   of doing it's own allocation.
   
   Tested (load/unload) on 2.5.74

<taowenhwa@intel.com> (03/07/10 1.1391)
   [e100] misc
   
   * Allow changing Wake On LAN when EEPROM disabled
   * Change Log updated
   * Version changed

<taowenhwa@intel.com> (03/07/10 1.1390)
   [e100] cu_start: timeout waiting for cu
   
   * Bug fix: 82557 (with National PHY) timeout during init
     [Adam Kropelin] akropel1@rochester.rr.com

<jcchen@icplus.com.tw> (03/07/10 1.1389)
   [netdrvr sundance] increase eeprom read timeout
