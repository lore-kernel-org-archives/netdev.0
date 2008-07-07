From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Mon, 07 Jul 2008 00:09:36 -0700 (PDT)
Message-ID: <20080707.000936.238740419.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:53837
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751272AbYGGHJg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jul 2008 03:09:36 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


A lot of smaller stuff:

1) Fix a test for impossible negative values in tcp_read_sock().
   From Octavian Purdila.

2) tcp.c needs scatterlist.h, thanks Andrew.

3) Use after free in bridging code, from Patrick McHardy.

4) CAN protocol code needs some missing sanity checks, from
   Oliver Hartkopp.

5) Wireless and wired bug fixes via John W. Linville and Jeff
   Garzik.

Please pull, thanks a lot!

The following changes since commit c461a973118346d5c103aaaddd62e53939fd7c67:
  Linus Torvalds (1):
        Merge branch 'for-linus' of git://git.kernel.org/.../jbarnes/pci-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Andrew Morton (1):
      tcp: net/ipv4/tcp.c needs linux/scatterlist.h

David S. Miller (1):
      Merge branch 'master' of master.kernel.org:/.../linville/wireless-2.6

Jan-Bernd Themann (3):
      ehea: fix might sleep problem
      ehea: add MODULE_DEVICE_TABLE
      ehea: fix race condition

Krzysztof Halasa (1):
      Add missing skb->dev assignment in Frame Relay RX code

Laurent Pinchart (1):
      fs_enet: restore promiscuous and multicast settings in restart()

Octavian Purdila (1):
      tcp: fix a size_t < 0 comparison in tcp_read_sock

Oliver Hartkopp (1):
      can: add sanity checks

Patrick McHardy (1):
      bridge: fix use-after-free in br_cleanup_bridges()

Rick Farrington (1):
      iwlwifi: fix incorrect 5GHz rates reported in monitor mode

Roland Dreier (2):
      ehea: Access iph->tot_len with correct endianness
      pasemi_mac: Access iph->tot_len with correct endianness

Sathya Narayanan (2):
      ibm_newemac: Fixes kernel crashes when speed of cable connected changes
      ibm_newemac: Fixes entry of short packets

Tobias Diedrich (1):
      forcedeth: fix lockdep warning on ethtool -s

Zhu Yi (1):
      iwlwifi: drop skb silently for Tx request in monitor mode

andrey@cozybit.com (1):
      libertas: support USB persistence on suspend/resume (resend)

 drivers/net/ehea/ehea.h                     |    8 +++--
 drivers/net/ehea/ehea_main.c                |   42 ++++++++++++++++-----------
 drivers/net/forcedeth.c                     |   15 ++++++++-
 drivers/net/fs_enet/mac-fcc.c               |    3 ++
 drivers/net/ibm_newemac/core.c              |    8 +++++
 drivers/net/pasemi_mac.c                    |    2 +-
 drivers/net/wan/hdlc_fr.c                   |    1 +
 drivers/net/wireless/iwlwifi/iwl-3945.c     |    6 +++-
 drivers/net/wireless/iwlwifi/iwl-4965.c     |    6 +++-
 drivers/net/wireless/iwlwifi/iwl3945-base.c |    3 +-
 drivers/net/wireless/iwlwifi/iwl4965-base.c |    3 +-
 drivers/net/wireless/libertas/if_usb.c      |    1 +
 net/bridge/br_if.c                          |   10 ++++--
 net/can/af_can.c                            |   10 ++++++
 net/can/bcm.c                               |   23 ++++++++++++--
 net/can/raw.c                               |    3 ++
 net/ipv4/tcp.c                              |    4 ++-
 17 files changed, 113 insertions(+), 35 deletions(-)
