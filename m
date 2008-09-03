From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Wed, 03 Sep 2008 16:13:41 -0700 (PDT)
Message-ID: <20080903.161341.239039051.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43294
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754686AbYICXNs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 3 Sep 2008 19:13:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Andrew Morton reported a build failure because the TIPC protocol
   layer defines a "struct node" but include/linux/node.h does the
   same.  I added a "tipc_" prefix to TIPC's datastructure names to
   fix this.

2) bnx2x driver accesses 64 bytes past the end of a DMA mapping, oops.
   Fix from Eilon Greenstein.

3) Two ath9k fixes form Jouni Malinen, one for TX control flag settings	
   when we have no ACK for RTS/CTS and another fix for TX status reporting.

4) Several iwlwifi fixes:
   a) STATUS_EXIT_PENDING needs to be set during pci_remove or else the device
      doesn't get shutdown properly
   b) chip doesn't go into low power mode when the driver does a suspend or
      an exit, add missing apm stop call to fix that
   c) TX command memory allocation failures not handled properly, resulting
      in leak
   d) RX chain values miscalculated, this causes a firmware error and reset
   e) MIMO power save values were wrong, it was using the local values rather
      than the peer's
   f) spurious Full-RXON events cause reconnection to the AP making the
      connection nearly unusable, do not emit these during power save
      transitions
   g) hidden non-broadcasting APs on passive channels could not be seen
      because direct probes were not being sent even if traffic was
      detected on that channel
   h) driver erroneously indicates that chip can do proper TSF syncing,
      it really cannot do this properly so don't set the feature bit

5) Remove netxen chipset quirk, it causes DMA lockups instead of fixing
   the problem.  From Dhananjay Phadke.

6) pcnet-cs and axnet-cs, add some new PCI IDs, from Komuro.

7) In IXGBE, the default interrupt throttling setting was unintentionally
   removed in 2.6.25, so now "0" is the default which kills performance.
   Fix from Andy Gospodarek.

8) Pegasus driver is way too verbose during startup, from David Brownell.

Please pull, thanks a lot!

The following changes since commit 37b08e34a98c664bea86e3fae718ac45a46b7276:
  David S. Miller (1):
        ipsec: Fix deadlock in xfrm_state management.

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andy Gospodarek (1):
      ixgbe: initialize interrupt throttle rate

Assaf Krauss (1):
      iwlwifi: W/A for the TSF correction in IBSS

David Brownell (1):
      net/usb/pegasus: avoid hundreds of diagnostics

David S. Miller (3):
      tipc: Don't use structure names which easily globally conflict.
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6
      Merge branch 'davem-fixes' of master.kernel.org:/.../jgarzik/netdev-2.6

Dhananjay Phadke (1):
      netxen: Remove workaround for chipset quirk

Eilon Greenstein (1):
      bnx2x: Accessing un-mapped page

Gregory Greenman (2):
      iwlwifi: call apm stop on exit
      iwlwifi: fix STATUS_EXIT_PENDING is not set on pci_remove

Jouni Malinen (2):
      ath9k: Fix TX status reporting
      ath9k: Fix TX control flag use for no ACK and RTS/CTS

Komuro (1):
      pcnet-cs, axnet_cs: add new IDs, remove dup ID with less info

Mohamed Abbas (1):
      iwlwifi: remove false rxon if rx chain changes

Ron Rindjunsky (2):
      iwlwifi: fix hidden ssid discovery in passive channels
      iwlwifi: fix station mimo power save values

Tomas Winkler (2):
      iwlwifi: fix rx_chain computation
      iwlwifi: fix Tx cmd memory allocation failure handling

 drivers/net/bnx2x.h                       |    5 +-
 drivers/net/bnx2x_main.c                  |   34 ++++++------
 drivers/net/ixgbe/ixgbe_main.c            |    6 ++
 drivers/net/netxen/netxen_nic_main.c      |   10 ----
 drivers/net/pcmcia/axnet_cs.c             |    1 +
 drivers/net/pcmcia/pcnet_cs.c             |    2 +-
 drivers/net/usb/pegasus.c                 |   11 ++--
 drivers/net/wireless/ath9k/main.c         |   12 ++++-
 drivers/net/wireless/ath9k/xmit.c         |    4 +-
 drivers/net/wireless/iwlwifi/iwl-agn-rs.c |    3 +-
 drivers/net/wireless/iwlwifi/iwl-agn.c    |   27 ++++++-----
 drivers/net/wireless/iwlwifi/iwl-core.c   |   77 +++++++++++++++++------------
 drivers/net/wireless/iwlwifi/iwl-dev.h    |    1 -
 drivers/net/wireless/iwlwifi/iwl-rx.c     |    5 ++-
 drivers/net/wireless/iwlwifi/iwl-scan.c   |    2 +-
 drivers/net/wireless/iwlwifi/iwl-tx.c     |   27 ++++++----
 net/tipc/bcast.c                          |   22 ++++----
 net/tipc/bcast.h                          |   22 ++++----
 net/tipc/bearer.c                         |    2 +-
 net/tipc/bearer.h                         |    2 +-
 net/tipc/cluster.c                        |   16 +++---
 net/tipc/cluster.h                        |   10 ++--
 net/tipc/discover.c                       |    2 +-
 net/tipc/link.c                           |   26 +++++-----
 net/tipc/link.h                           |    2 +-
 net/tipc/name_table.h                     |    2 +-
 net/tipc/net.c                            |    2 +-
 net/tipc/net.h                            |    2 +-
 net/tipc/node.c                           |   60 +++++++++++-----------
 net/tipc/node.h                           |   42 ++++++++--------
 net/tipc/node_subscr.c                    |    4 +-
 net/tipc/node_subscr.h                    |   10 ++--
 net/tipc/port.h                           |    2 +-
 net/tipc/zone.c                           |    4 +-
 net/tipc/zone.h                           |    2 +-
 35 files changed, 248 insertions(+), 213 deletions(-)
