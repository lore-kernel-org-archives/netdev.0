From: Jan Niehusmann <jan@gondor.com>
Subject: TX VLAN acceleration on bridges broken in 2.6.37?
Date: Tue, 22 Feb 2011 00:29:02 +0100
Message-ID: <20110221232902.GA3440@x61s.reliablesolutions.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

With the following configuration, sending vlan tagged traffic from a
bridged interface doesn't work in 2.6.37.
The same configuration does work with 2.6.36:

- bridge br0 with physical interface eth0
- eth0 being an e1000e device (don't know if that's important)
- vlan interface br0.10
- (on 2.6.37) tx vlan acceleration active on br0 (default)

Networking on br0.10 doesn't work, and tcpdump on eth0 shows packets
sent on br0.10 as untagged, instead of vlan 10 tagged.

After turning vlan tx offloading off with 'ethtool -K br0 txvlan off',
everything works as expected, again.

The workaround is made permanent by reverting "bridge: Add support for
TX vlan offload.", 361ff8a6cf90d62c0071b7e532e37369bfd3ae77, turning
of the feature on bridges completely.

Jan
