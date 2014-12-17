From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH 00/10] Split UFO into v4 and v6 versions.
Date: Wed, 17 Dec 2014 13:20:45 -0500
Message-ID: <1418840455-22598-1-git-send-email-vyasevic@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: mst@redhat.com, ben@decadent.org.uk, stefanha@redhat.com,
	virtualization@lists.linux-foundation.org
To: netdev@vger.kernel.org
Return-path: <virtualization-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/virtualization/>
List-Post: <mailto:virtualization@lists.linux-foundation.org>
List-Help: <mailto:virtualization-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/virtualization>,
	<mailto:virtualization-request@lists.linux-foundation.org?subject=subscribe>
Sender: virtualization-bounces@lists.linux-foundation.org
Errors-To: virtualization-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

UFO support in the kernel applies to both IPv4 and IPv6 protocols
with the same device feature.  However some devices may not be able
to support one of the offloads.  For this we split the UFO offload
feature into 2 pieces.  NETIF_F_UFO now controlls the IPv4 part and
this series introduces NETIF_F_UFO6.

As a result of this work, we can now re-enable NETIF_F_UFO on
virtio_net devices and restore UDP over IPv4 performance for guests.
We also continue to support legacy guests that assume that UFO6
support included into UFO(4).

Without this work, migrating a guest to a 3.18 kernel fails.

Vladislav Yasevich (10):
  core: Split out UFO6 support
  net:  Correctly mark IPv6 UFO offload type.
  ovs: Enable handling of UFO6 packets.
  loopback: Turn on UFO6 support.
  veth: Enable UFO6 support.
  macvlan: Enable UFO6 support.
  s2io: Enable UFO6 support.
  tun: Re-uanble UFO support.
  macvtap: Re-enable UFO support
  Revert "drivers/net: Disable UFO through virtio"

 drivers/net/ethernet/neterion/s2io.c |  6 +++---
 drivers/net/loopback.c               |  4 ++--
 drivers/net/macvlan.c                |  2 +-
 drivers/net/macvtap.c                | 20 ++++++++++++++------
 drivers/net/tun.c                    | 26 ++++++++++++++------------
 drivers/net/veth.c                   |  2 +-
 drivers/net/virtio_net.c             | 24 ++++++++++--------------
 include/linux/netdev_features.h      |  7 +++++--
 include/linux/netdevice.h            |  1 +
 include/linux/skbuff.h               |  1 +
 net/core/dev.c                       | 35 +++++++++++++++++++----------------
 net/core/ethtool.c                   |  2 +-
 net/ipv6/ip6_offload.c               |  1 +
 net/ipv6/ip6_output.c                |  4 ++--
 net/ipv6/udp_offload.c               |  3 ++-
 net/mpls/mpls_gso.c                  |  1 +
 net/openvswitch/datapath.c           |  3 ++-
 net/openvswitch/flow.c               |  2 +-
 18 files changed, 81 insertions(+), 63 deletions(-)

-- 
1.9.3
