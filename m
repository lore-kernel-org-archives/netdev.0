From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/8][pull request] Intel Wired LAN Driver Updates
Date: Thu, 25 Apr 2013 21:57:03 -0700
Message-ID: <1366952231-16727-1-git-send-email-jeffrey.t.kirsher@intel.com>
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
	gospo@redhat.com, sassmann@redhat.com, bhutchings@solarflare.com,
	stable@vger.kernel.org
To: davem@davemloft.net
Return-path: <stable-owner@vger.kernel.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This series contains updates to e1000e, igb and ixgbe.

There are 2 patches in this series which could be applied to net,
but since Linus is so very close to releasing 3.9, I do not think
it prudent to try and push these into net at this time.  I have CC'd
stable on these patches so that they can queue them up as soon as
3.9 gets released.

The 2 patches are:
  e1000e: fix numeric overflow in phc settime method
  ixgbe: fix EICR write in ixgbe_msix_other

Richard provides a fix for e1000e by using a helper function from time.h
to resolve a unintended overflow in the PTP settime function.

Bruce provides a fix to wait for NAPI to be done with the current context
after disabling interrupts and then disable NAPI when the interface
is going down.  This fixes a possible "unable to handle kernel paging
request" panic in net-next.

Andi Kleen provides a patch for igb to use mdelay instead of udelay
when we needed 100000us.

Jacob provides a fix for ixgbe to simply mask the lower 16bits off so that
ixgbe_msix_other does not write them in the EICR, which causes them to
remain high and be properly handled by the clean_rings interrupt routine
as normal.

Emil cleans up the logic in ixgbe_setup_loopback_test() to only access
registers applicable to the MAC type.  In addition, removes majority
of the AUTOC register reads by using a cached value instead to avoid
writing corrupted values to AUTOC due to bad FW.  Emil also add support
for disabling link during boot time.  Lastly, he provides a patch which
adds the MAC type to the version in ethtool_regs which will make it
easier to check the MAC type when dumping registers with ethtool.

There is a separate ethtool tool patch which is dependent upon Emil's
last patch of the series to add the MAC type to the version in
ethtool_regs, which will be sent separately.

The following are changes since commit 3a4e0d6a95b2b6f7b22eb7c7361a0fc4289478eb:
  openvswitch: Use parallel_ops genl.
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/net-next master

Andi Kleen (1):
  igb: limit udelay for phy changes to 10000us

Bruce Allan (1):
  e1000e: panic caused by Rx traffic arriving while interface going
    down

Emil Tantilov (4):
  ixgbe: fix register access during ethtool loopback test
  ixgbe: cache AUTOC reads
  ixgbe: add support for disabling link at boot time on 82599
  ixgbe: add mac type to the version in ethtool_regs

Jacob Keller (1):
  ixgbe: fix EICR write in ixgbe_msix_other

Richard Cochran (1):
  e1000e: fix numeric overflow in phc settime method

 drivers/net/ethernet/intel/e1000e/netdev.c       |  7 ++-
 drivers/net/ethernet/intel/e1000e/ptp.c          |  3 +-
 drivers/net/ethernet/intel/igb/e1000_phy.c       |  6 +--
 drivers/net/ethernet/intel/ixgbe/ixgbe_82599.c   | 61 +++++++++++++++++-------
 drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c | 29 ++++++-----
 drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    | 10 ++++
 drivers/net/ethernet/intel/ixgbe/ixgbe_type.h    |  2 +
 7 files changed, 80 insertions(+), 38 deletions(-)

-- 
1.7.11.7
