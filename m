From: David Miller <davem@davemloft.net>
Subject: [GIT]: Networking
Date: Tue, 23 Feb 2010 19:13:47 -0800 (PST)
Message-ID: <20100223.191347.124292181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34692
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754911Ab0BXDNb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Feb 2010 22:13:31 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


1) Wireless fixes from Linville and co. in particular an
   iwlwifi tfd freeing issue that many people are likely to hit.

2) GRO handling uses napi->dev when it should use skb->dev,
   breaking VLAN + GRO.  Fix from Ajit Khaparde.

3) Make IPV6 max_addresses sysctl documentation clearer.

4) Add new device ID to cdc_ether, from Torgny Johansson.

5) tc35815 double netif_wake_queue()s, triggering a BUG().
   Fix from Atsushi Nemoto.

6) DMA mapping error handlng on RX in e1000 driver crashes under
   load.  Fix from Anton Blanchard.

7) MAINTAINERS update for mv643xx_eth.

Please pull, thanks a lot!

The following changes since commit be64c970f601d5bb439b6cc88ea2bd208b3422a0:
  Linus Torvalds (1):
        Merge branch 'release' of git://git.kernel.org/.../lenb/linux-acpi-2.6

are available in the git repository at:

  master.kernel.org:/pub/scm/linux/kernel/git/davem/net-2.6.git master

Ajit Khaparde (1):
      net: bug fix for vlan + gro issue

Anton Blanchard (1):
      e1000: Fix DMA mapping error handling on RX

Atsushi Nemoto (1):
      tc35815: Remove a wrong netif_wake_queue() call which triggers BUG_ON

Brian Haley (1):
      IPv6: better document max_addresses parameter

Dan Halperin (1):
      iwlwifi: set HT flags after channel in rxon

David S. Miller (1):
      Merge branch 'master' of git://git.kernel.org/.../linville/wireless-2.6

Lennert Buytenhek (1):
      MAINTAINERS: update mv643xx_eth maintenance status

Stanislaw Gruszka (1):
      iwlwifi: sanity check before counting number of tfds can be free

Torgny Johansson (1):
      cdc_ether: new PID for Ericsson C3607w to the whitelist (resubmit)

Wey-Yi Guy (1):
      iwlwifi: error checking for number of tfds in queue

 Documentation/networking/ip-sysctl.txt  |    8 ++++----
 MAINTAINERS                             |    4 ++--
 drivers/net/e1000/e1000_main.c          |   19 ++++++++++++++++++-
 drivers/net/tc35815.c                   |    1 -
 drivers/net/usb/cdc_ether.c             |    5 +++++
 drivers/net/wireless/iwlwifi/iwl-4965.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-5000.c |    8 +++-----
 drivers/net/wireless/iwlwifi/iwl-core.c |    2 +-
 drivers/net/wireless/iwlwifi/iwl-core.h |    2 ++
 drivers/net/wireless/iwlwifi/iwl-tx.c   |   22 ++++++++++++++++++++--
 net/core/dev.c                          |    2 +-
 11 files changed, 57 insertions(+), 18 deletions(-)
