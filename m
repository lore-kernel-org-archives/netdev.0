From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: Re: [PATCH/RFC net-next 0/4] Delete token ring support.
Date: Tue, 15 May 2012 23:05:10 -0400
Message-ID: <20120516030510.GB26701@windriver.com>
References: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
 <m2k40dkl2o.fsf@firstfloor.org>
 <20120515.210020.1631343759962418692.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <andi@firstfloor.org>, <netdev@vger.kernel.org>,
	<schwidefsky@de.ibm.com>, <heiko.carstens@de.ibm.com>,
	<linux390@de.ibm.com>, <linux-s390@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:61252 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966399Ab2EPDFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 23:05:23 -0400
Content-Disposition: inline
In-Reply-To: <20120515.210020.1631343759962418692.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Re: [PATCH/RFC net-next 0/4] Delete token ring support.] On 15/05/2012 (Tue 21:00) David Miller wrote:

> From: Andi Kleen <andi@firstfloor.org>
> Date: Tue, 15 May 2012 17:48:15 -0700
> 
> > Paul Gortmaker <paul.gortmaker@windriver.com> writes:
> >>
> >> What I mean by (2) is the implicit absence of anyone fixing _runtime_
> >> bugs, going all the way back to 2.6.12 in 2005.  If the code was being
> >> _used_, we'd see runtime regressions reported and their associated
> >> fixes.
> > 
> > Removal sounds good to me. In fact I would argue to remove any other driver
> > which did not get a real change since 2005 too.
> 
> I also support removing the token ring stuff, and in fact I'm more
> than happy to add your patch set to the net-next tree right now.

I've re-run i386 allyesconfig/allmodconfig, since I'd not re-run that
after deleting the firmware blobs.   Fortunately nothing showed up, so
this pull is unchanged from the RFC sent earlier today.  (I'd run the
s390 defconfig just hours ago, so I knew that arch was OK already)

Thanks,
Paul.
---

Please pull:

The following changes since commit e87cc4728f0e2fb663e592a1141742b1d6c63256:

  net: Convert net_ratelimit uses to net_<level>_ratelimited (2012-05-15 13:45:03 -0400)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-tokenring

for you to fetch changes up to ee446fd5e6dafee4a16fd1bd345d2571dcfd6f5d:

  tokenring: delete all remaining driver support (2012-05-15 20:23:16 -0400)

----------------------------------------------------------------
Paul Gortmaker (4):
      s390: delete any traces of token ring support
      atm: remove the coupling to token ring support
      net: delete all instances of special processing for token ring
      tokenring: delete all remaining driver support

 Documentation/filesystems/proc.txt    |    1 -
 Documentation/networking/00-INDEX     |    8 -
 Documentation/networking/3c359.txt    |   58 -
 Documentation/networking/olympic.txt  |   79 -
 Documentation/networking/smctr.txt    |   66 -
 Documentation/networking/tms380tr.txt |  147 -
 arch/mips/configs/mtx1_defconfig      |    4 -
 arch/xtensa/configs/common_defconfig  |    5 -
 drivers/message/fusion/mptlan.h       |    1 -
 drivers/net/Kconfig                   |    2 -
 drivers/net/Makefile                  |    1 -
 drivers/net/Space.c                   |   46 -
 drivers/net/tokenring/3c359.c         | 1831 -----------
 drivers/net/tokenring/3c359.h         |  291 --
 drivers/net/tokenring/Kconfig         |  199 --
 drivers/net/tokenring/Makefile        |   16 -
 drivers/net/tokenring/abyss.c         |  468 ---
 drivers/net/tokenring/abyss.h         |   58 -
 drivers/net/tokenring/ibmtr.c         | 1964 -----------
 drivers/net/tokenring/ibmtr_cs.c      |  370 ---
 drivers/net/tokenring/lanstreamer.c   | 1909 -----------
 drivers/net/tokenring/lanstreamer.h   |  343 --
 drivers/net/tokenring/madgemc.c       |  761 -----
 drivers/net/tokenring/madgemc.h       |   70 -
 drivers/net/tokenring/olympic.c       | 1737 ----------
 drivers/net/tokenring/olympic.h       |  321 --
 drivers/net/tokenring/proteon.c       |  422 ---
 drivers/net/tokenring/skisa.c         |  432 ---
 drivers/net/tokenring/smctr.c         | 5717 ---------------------------------
 drivers/net/tokenring/smctr.h         | 1585 ---------
 drivers/net/tokenring/tms380tr.c      | 2306 -------------
 drivers/net/tokenring/tms380tr.h      | 1141 -------
 drivers/net/tokenring/tmspci.c        |  236 --
 drivers/s390/net/Kconfig              |    5 +-
 drivers/s390/net/lcs.c                |   21 +-
 drivers/s390/net/qeth_core.h          |    2 -
 drivers/s390/net/qeth_core_main.c     |    6 +-
 drivers/s390/net/qeth_l3_main.c       |   35 +-
 firmware/3com/3C359.bin.ihex          | 1573 ---------
 firmware/Makefile                     |    2 -
 firmware/WHENCE                       |   38 -
 firmware/tr_smctr.bin.ihex            |  477 ---
 include/linux/Kbuild                  |    1 -
 include/linux/atmlec.h                |    7 -
 include/linux/ibmtr.h                 |  373 ---
 include/linux/if_arp.h                |    2 +-
 include/linux/if_tr.h                 |  103 -
 include/linux/ipx.h                   |    2 +-
 include/linux/trdevice.h              |   37 -
 include/net/if_inet6.h                |   54 -
 include/net/ip.h                      |   17 -
 include/net/llc_pdu.h                 |    7 -
 net/802/Makefile                      |    1 -
 net/802/p8022.c                       |    3 +-
 net/802/tr.c                          |  670 ----
 net/atm/lec.c                         |  138 +-
 net/atm/lec.h                         |    1 -
 net/core/dev.c                        |   14 +-
 net/ipv4/Kconfig                      |    4 +-
 net/ipv4/arp.c                        |   13 +-
 net/ipv4/ipconfig.c                   |    2 -
 net/ipv6/addrconf.c                   |    2 -
 net/ipv6/ndisc.c                      |   17 -
 net/ipx/af_ipx.c                      |   10 +-
 net/llc/af_llc.c                      |    3 +-
 net/llc/llc_output.c                  |    3 -
 net/llc/llc_sap.c                     |    4 -
 net/sysctl_net.c                      |    4 -
 68 files changed, 33 insertions(+), 26213 deletions(-)
 delete mode 100644 Documentation/networking/3c359.txt
 delete mode 100644 Documentation/networking/olympic.txt
 delete mode 100644 Documentation/networking/smctr.txt
 delete mode 100644 Documentation/networking/tms380tr.txt
 delete mode 100644 drivers/net/tokenring/3c359.c
 delete mode 100644 drivers/net/tokenring/3c359.h
 delete mode 100644 drivers/net/tokenring/Kconfig
 delete mode 100644 drivers/net/tokenring/Makefile
 delete mode 100644 drivers/net/tokenring/abyss.c
 delete mode 100644 drivers/net/tokenring/abyss.h
 delete mode 100644 drivers/net/tokenring/ibmtr.c
 delete mode 100644 drivers/net/tokenring/ibmtr_cs.c
 delete mode 100644 drivers/net/tokenring/lanstreamer.c
 delete mode 100644 drivers/net/tokenring/lanstreamer.h
 delete mode 100644 drivers/net/tokenring/madgemc.c
 delete mode 100644 drivers/net/tokenring/madgemc.h
 delete mode 100644 drivers/net/tokenring/olympic.c
 delete mode 100644 drivers/net/tokenring/olympic.h
 delete mode 100644 drivers/net/tokenring/proteon.c
 delete mode 100644 drivers/net/tokenring/skisa.c
 delete mode 100644 drivers/net/tokenring/smctr.c
 delete mode 100644 drivers/net/tokenring/smctr.h
 delete mode 100644 drivers/net/tokenring/tms380tr.c
 delete mode 100644 drivers/net/tokenring/tms380tr.h
 delete mode 100644 drivers/net/tokenring/tmspci.c
 delete mode 100644 firmware/3com/3C359.bin.ihex
 delete mode 100644 firmware/tr_smctr.bin.ihex
 delete mode 100644 include/linux/ibmtr.h
 delete mode 100644 include/linux/if_tr.h
 delete mode 100644 include/linux/trdevice.h
 delete mode 100644 net/802/tr.c
