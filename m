From: Amir Vadai <amirv@mellanox.com>
Subject: [PATCH V1 net-next 0/4] Add destination MAC address to ethtool flow steering
Date: Wed, 12 Dec 2012 14:13:16 +0200
Message-ID: <1355314400-14909-1-git-send-email-amirv@mellanox.com>
Cc: netdev@vger.kernel.org, Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Hadar Har-Zion <hadarh@mellanox.com>,
	Yan Burman <yanb@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog113.obsmtp.com ([207.126.144.135]:35787 "HELO
	eu1sys200aog113.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1751494Ab2LLMNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Dec 2012 07:13:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yan Burman <yanb@mellanox.com>

In vSwitch configuration it is often beneficial to create flow steering
rules for L3/L4 traffic based on VM port. This requires destination MAC
address of that port to be present. Note that today the mlx4_en driver 
adds the mac address of itself to the flow spec, where under the new
ethtool flag suggested here it doesn't.

It may also be useful in macvlan devices.

These patches add kernel support for the new field (does not break old
userspace compatibility, so new ethtool will work on old kernels and
old ethtool will work with new kernels).

Also present here is the ethtool userspace patch.

See more details here http ://marc.info/?t=134977576500003

Changes from V0:
- Get rid of full_mac, zero_mac in favour of
    is_zero_ether_addr and is_broadcast_ether_addr

Yan Burman (3):
  net: ethtool: Add destination MAC address to flow steering API
  net/mlx4_en: Use generic etherdevice.h functions.
  net/mlx4_en: Add support for destination MAC in steering rules

 drivers/net/ethernet/mellanox/mlx4/en_ethtool.c | 27 ++++++++++++++++---------
 include/uapi/linux/ethtool.h                    | 11 ++++++----
 2 files changed, 24 insertions(+), 14 deletions(-)

-- 
1.7.11.3
