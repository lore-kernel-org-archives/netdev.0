From: Ben Hutchings <bhutchings@solarflare.com>
Subject: pull request: sfc-next-2.6 2011-04-05
Date: Tue, 05 Apr 2011 19:00:46 +0100
Message-ID: <1302026446.2932.56.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	sf-linux-drivers <linux-net-drivers@solarflare.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirq-linux@rere.qmqm.pl>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.solarflare.com ([216.237.3.220]:14926 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750807Ab1DESAt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2011 14:00:49 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The following changes since commit 9b12c75bf4d58dd85c987ee7b6a4356fdc7c1222:

  net: Order ports in same order as addresses in flow objects. (2011-03-31 18:03:35 -0700)

are available in the git repository at:
  git://git.kernel.org/pub/scm/linux/kernel/git/bwh/sfc-next-2.6.git for-davem

1. Implement generic features interface in sfc.
2. Update ethtool_ops documentation.
3. Reimplement ETHTOOL_PHYS_ID as dicussed, dropping the RTNL lock.

Changes since the previous request:

1a. Drop NETIF_F_GRO from net_device::features; let the core enable it.
1b. Add NETIF_F_ALL_TSO and NETIF_F_RXCSUM to net_device::vlan_features;
TSO-IPv6 and RX checksum offload do work with VLAN-tagged packets.
2. In comments on deprecated offload control operations, refer to
'generic netdev features' rather than 'the netdev op ndo_set_flags'.
Add a note at the bottom referring to struct net_device and struct
net_device_ops.
3a. Change comment 'must set the state' to 'should set the state'. We
don't really care if ON and OFF get inverted, and some of Stephen's
implementations just invert the LED state in either case.
3b. Prevent reentry of the ETHTOOL_PHYS_ID loop.

Ben.

Ben Hutchings (7):
      sfc: Move test of rx_checksum_enabled from nic.c to rx.c
      sfc: Enable all TSO features on VLANs
      sfc: Implement generic features interface
      ethtool: Convert struct ethtool_ops comment to kernel-doc format
      ethtool: Fill out and update comment for struct ethtool_ops
      ethtool: Change ETHTOOL_PHYS_ID implementation to allow dropping RTNL
      sfc: Implement ethtool_ops::set_phys_id instead of ethtool_ops::phys_id

 drivers/net/sfc/efx.c        |   20 ++++-
 drivers/net/sfc/ethtool.c    |  106 ++++--------------------
 drivers/net/sfc/net_driver.h |    2 -
 drivers/net/sfc/nic.c        |    6 +-
 drivers/net/sfc/rx.c         |    3 +
 include/linux/ethtool.h      |  180 ++++++++++++++++++++++++++++++------------
 net/core/ethtool.c           |   55 ++++++++++++-
 7 files changed, 223 insertions(+), 149 deletions(-)

-- 
Ben Hutchings, Senior Software Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

