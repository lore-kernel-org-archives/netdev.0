From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Fri, 19 Feb 2010 17:09:29 -0800 (PST)
Message-ID: <20100219.170929.57457581.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some stragglers.  I know it's late but I really would be
remiss to not submit the sysctl fixes.

1) When we fixed a deadlock on the RTNL lock, when writing to
   forwarding control sysctl values while at the same time
   removing a device, we added a new bug.  The commit was
   9b8adb5ea005 ("net: Fix devinet_sysctl_forward")

   By the time these sysctl handlers have been called, the
   generic sysctl code has already changed the value of the
   integer.  So if we retry to avoid a deadlock, we have to
   undo that modification.

   Fix from Eric W. Biederman.

2) When the the wireless get stats output method were changed to use
   the RTNL lock instead of dev_base_lock (commit a160ee69c6a "wext:
   let get_wireless_stats() sleep") , it acquired the same kind of
   deadlock that the forwarding controls have.  Fix it in the same
   way.

   Also from Eric W. Biederman.

3) Two SFC driver bug fixes from Ben Hucthings.  First, propagate
   properly signed error codes back from efc_mcdi_poll_reboot()
   and also adjust temperature and voltage tolerances so that they
   do not prematurely trigger.

Please pull, thanks a lot!

The following changes since commit f8b55f251012e104093e105483c45c5d85ad3040:
  Christine Caulfield (1):
        Orphan DECnet

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ben Hutchings (2):
      sfc: Fix sign of efx_mcdi_poll_reboot() error in efx_mcdi_poll()
      sfc: SFE4002/SFN4112F: Widen temperature and voltage tolerances

Eric W. Biederman (2):
      net: Fix sysctl restarts...
      net-sysfs: Use rtnl_trylock in wireless sysfs methods.

 drivers/net/sfc/falcon_boards.c |   45 +++++++++++++++++++++++---------------
 drivers/net/sfc/mcdi.c          |    2 +-
 net/core/net-sysfs.c            |    3 +-
 net/ipv4/devinet.c              |    7 +++++-
 net/ipv6/addrconf.c             |   16 ++++++++++++-
 5 files changed, 50 insertions(+), 23 deletions(-)
