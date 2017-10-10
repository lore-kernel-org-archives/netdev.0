From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next 0/9][pull request] 1GbE Intel Wired LAN Driver Updates 2017-10-10
Date: Tue, 10 Oct 2017 10:21:30 -0700
Message-ID: <20171010172139.77914-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, netdev@vger.kernel.org,
        nhorman@redhat.com, sassmann@redhat.com, jogreene@redhat.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:11575 "EHLO mga11.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S932069AbdJJRWA (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 10 Oct 2017 13:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series contains updates to e1000e and igb.

Benjamin Poirier provides several fixes for e1000e, starting with a
correction to the return status which was always returning success even
if it was not successful.  Fixed code comments to reflect the actual
code behavior.  Fixed the conditional test for the correct return
value.  Fixed a potential race condition reported by Lennart Sorensen,
where the single flag get_link_status is used to signal two different
states.

Sasha fixes a buffer overrun for i219 devices, where the chipset had
reduced the round-trip latency for the LAN controller DMA accesses
which in some high performance cases caused a buffer overrun while
processing the DMA transactions.

Willem de Bruijn changes the default behavior of e1000e to use the
burst mode settings by default unless the user specifies the
receive interrupt delay (RxIntDelay).

Florian Fainelli updates the driver to differentiate between when
e1000e_put_txbuf() is called from normal reclamation or when a
DMA mapping failure to make the driver more "drop monitor friendly".

Christophe JAILLET fixes a potential NULL pointer dereference by
properly returning -ENOMEM on memory allocation failures.

The following are changes since commit 812b5ca7d376e7e008ac0c897d1ef94eb05ddc3b:
  Add a driver for Renesas uPD60620 and uPD60620A PHYs
and are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/jkirsher/next-queue 1GbE

Benjamin Poirier (5):
  e1000e: Fix error path in link detection
  e1000e: Fix wrong comment related to link detection
  e1000e: Fix return value test
  e1000e: Separate signaling for link check/link up
  e1000e: Avoid receiver overrun interrupt bursts

Christophe JAILLET (1):
  igb: check memory allocation failure

Florian Fainelli (1):
  e1000e: Be drop monitor friendly

Sasha Neftin (1):
  e1000e: fix buffer overrun while the I219 is processing DMA
    transactions

Willem de Bruijn (1):
  e1000e: apply burst mode settings only on default

 drivers/net/ethernet/intel/e1000e/defines.h |  1 +
 drivers/net/ethernet/intel/e1000e/e1000.h   |  4 --
 drivers/net/ethernet/intel/e1000e/mac.c     | 11 +++--
 drivers/net/ethernet/intel/e1000e/netdev.c  | 75 +++++++++++++++++------------
 drivers/net/ethernet/intel/e1000e/param.c   | 16 +++++-
 drivers/net/ethernet/intel/e1000e/phy.c     |  7 +--
 drivers/net/ethernet/intel/igb/igb_main.c   |  2 +
 7 files changed, 75 insertions(+), 41 deletions(-)

-- 
2.14.2
