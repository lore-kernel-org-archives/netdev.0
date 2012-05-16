From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH/RFC net-next 0/4] Delete token ring support.
Date: Tue, 15 May 2012 20:35:40 -0400
Message-ID: <1337128544-18680-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Martin Schwidefsky <schwidefsky@de.ibm.com>,
	Heiko Carstens <heiko.carstens@de.ibm.com>,
	linux390@de.ibm.com, linux-s390@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:44420 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933377Ab2EPAgO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 May 2012 20:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This may not be for 35-next, but for addition to feature-removal.txt
and application at a later date.  But what I would like to get is
consensus that this is something that we want to proceed with before I
spend any more time on it.  If folks are OK with the idea, then I am
open to suggestions as to the best time for it to happen.

So, why you might ask?  It is in tree already, it is "free" to leave it
there, right?  Well, no.

What led me here was the creation of a patch to remove CONFIG_MCA.  In
doing so, I found I was deleting most of the token ring drivers, and 
altering the remaining few ISA/MCA ones to be just ISA only.

But it really didn't make sense to me, to just leave the skeletal
remains of token ring there -- vs removing TR 1st, and then the MCA
removal will be a lot smaller and cleaner commit.

Removal: does it make sense?

The biggest data point I can suggest to folks is to run:

	git whatchanged --follow drivers/net/tokenring

and when you are quickly paging over the changes, note two things.
(1) the amount of time spent by folks cleaning and maintaining the
code, and (2) - most important -- is that essentially all the commits
are of the tree-wide cleanup nature, or API change nature.

What I mean by (2) is the implicit absence of anyone fixing _runtime_
bugs, going all the way back to 2.6.12 in 2005.  If the code was being
_used_, we'd see runtime regressions reported and their associated fixes.

A search on the internet for users tends to show that even the die hard
enthusiasts who cared to poke at MCA/TR just for hobby sake have pretty
much all given up somewhere in the 2003-2005 "pre-git" timeframe, and
never really moved off their 2.4.x kernels.

This is no surprise, since on x86, MCA (and hence most tokenring
users) was limited to the lowly 386sx-16 PS/2 with typically 4MB RAM.
Some "high end" 486 machines existed, and in theory could be fitted
with max 64MB RAM (default 16MB).  I don't think anyone will debate
that such hardware with such limited memory is ever going to be useful
in a 3.x kernel use case.

The one thing I wasn't aware of, until actually creating the commits
to remove tokenring, was that s390 also had support for it.  I'm
guessing that it is just as unused there as it is on x86, but the s390
folks are CC'd for their input.

I've created separate commits for the removal of the core networking
support (i.e. net/*) vs. the drivers removal (i.e. drivers/net).  This
is a somewhat artifical separation, since one is useless without the
other, but it makes for easier review, and is still fully bisectable.
These can easily be squished into one commit if folks have a
preference one way or the other.

I still want to double check a few things, but it is at a point where
people can clearly see what will be removed, so I think checking for
input now as an RFC makes sense.  Since it is an RFC, I've told git to
omit showing the full line-by-line deletion of whole files.  The
baseline used is net-next from today.

Thanks,
Paul.

---
Cc: Martin Schwidefsky <schwidefsky@de.ibm.com>
Cc: Heiko Carstens <heiko.carstens@de.ibm.com>
Cc: linux390@de.ibm.com
Cc: linux-s390@vger.kernel.org


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

-- 
1.7.9.1
