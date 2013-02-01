From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 0/2] Delete obsolete wanrouter support
Date: Fri,  1 Feb 2013 18:30:20 -0500
Message-ID: <1359761422-27629-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	Dan Carpenter <dan.carpenter@oracle.com>,
	Joe Perches <joe@perches.com>,
	Arnaldo Carvalho de Melo <acme@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:40064 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758031Ab3BAXao (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Feb 2013 18:30:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The removal of wanrouter code was originally listed in the (now
gone) feature removal file since May 2012, and an RFC of the
deletion was posted[1] in late 2012.  The overall concept was given
an OK, but defconfig contamination, build failures, etc. meant that
it didn't quite make it into mainline for 3.8.

Since that time, Dan discovered (via code audit) a runtime bug that
proves nobody has been using this for over four years[2].  With that
new information, I think it makes sense for someone to follow through
on Joe's original RFC and get this done for the 3.9 release.

In addition to resolving the build failures of the RFC by keeping
stub headers, this also splits the change into two parts, just like
the token ring removal did.  Part #1 decouples the mainline kernel
from the expired subsystem, and part #2 does the large scale
deletion of the subsystem content.

The advantage of the above, is that a "git blame" will never lead
you to a 4000+ line deletion commit.  The large scale deletion will
never show up in a "git blame" and hence the same advantages that we
get from the "--irreversible-delete" in the review stage of "git
format-patch" are also embedded into the git history itself.  This
may seem like a moot point to some, but for those who spend a
considerable amount of time data mining in the git history, this is
probably worth doing.

I have done build tests of all[mod/yes]config for both the stage 1
(Makefile and Kconfig) and stage 2 (full driver delete) as a sanity
check, and the issues with the previously posted RFC should be gone.

Speaking of "--irreversible-delete" -- these patches were created
with that option, so if you want to use them locally, you are going
to have to pull (location below) the content instead of doing a
"git am" of the mailed out content.
    
[1] http://patchwork.ozlabs.org/patch/198794/
[2] http://www.spinics.net/lists/netdev/msg218670.html

Thanks,
Paul.

Cc: Dan Carpenter <dan.carpenter@oracle.com>
Cc: Joe Perches <joe@perches.com>
Cc: Arnaldo Carvalho de Melo <acme@redhat.com>

---

The following changes since commit 1b13c97fae9c61dc20db8e0d0a72a29df29ac377:

  net/vxlan: Add ethtool drvinfo (2013-01-30 22:47:22 -0500)

are available in the git repository at:

  git://git.kernel.org/pub/scm/linux/kernel/git/paulg/linux.git delete-wanrouter

for you to fetch changes up to 6fcdf4facb85e7d54ff6195378dd2ba8e0baccc4:

  wanrouter: delete now orphaned header content, files/drivers (2013-01-31 19:56:35 -0500)

----------------------------------------------------------------
Paul Gortmaker (2):
      wanrouter: completely decouple obsolete code from kernel.
      wanrouter: delete now orphaned header content, files/drivers

 Documentation/ioctl/ioctl-number.txt |    2 +-
 Documentation/magic-number.txt       |    2 +-
 Documentation/zh_CN/magic-number.txt |    2 +-
 drivers/isdn/i4l/isdn_x25iface.h     |    1 -
 drivers/net/wan/Kconfig              |   54 --
 drivers/net/wan/Makefile             |    5 -
 drivers/net/wan/cycx_drv.c           |  569 ------------
 drivers/net/wan/cycx_main.c          |  346 --------
 drivers/net/wan/cycx_x25.c           | 1602 ----------------------------------
 include/linux/cyclomx.h              |   77 --
 include/linux/cycx_drv.h             |   64 --
 include/linux/wanrouter.h            |  127 +--
 include/uapi/linux/wanrouter.h       |  443 +---------
 net/Kconfig                          |    1 -
 net/Makefile                         |    1 -
 net/socket.c                         |    1 -
 net/wanrouter/Kconfig                |   27 -
 net/wanrouter/Makefile               |    7 -
 net/wanrouter/patchlevel             |    1 -
 net/wanrouter/wanmain.c              |  782 -----------------
 net/wanrouter/wanproc.c              |  380 --------
 21 files changed, 11 insertions(+), 4483 deletions(-)
 delete mode 100644 drivers/net/wan/cycx_drv.c
 delete mode 100644 drivers/net/wan/cycx_main.c
 delete mode 100644 drivers/net/wan/cycx_x25.c
 delete mode 100644 include/linux/cyclomx.h
 delete mode 100644 include/linux/cycx_drv.h
 delete mode 100644 net/wanrouter/Kconfig
 delete mode 100644 net/wanrouter/Makefile
 delete mode 100644 net/wanrouter/patchlevel
 delete mode 100644 net/wanrouter/wanmain.c
 delete mode 100644 net/wanrouter/wanproc.c
