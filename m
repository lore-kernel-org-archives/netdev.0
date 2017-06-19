From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next v3 0/6] vxlan: cleanup and IPv6 link-local support
Date: Mon, 19 Jun 2017 10:03:54 +0200
Message-ID: <cover.1497825555.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, dev@openvswitch.org,
        linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Running VXLANs over IPv6 link-local addresses allows to use them as a
drop-in replacement for VLANs, avoiding to allocate additional outer IP
addresses to run the VXLAN over.

Since v1, I have added a lot more consistency checks to the address
configuration, making sure address families and scopes match. To simplify
the implementation, I also did some general refactoring of the
configuration handling in the new first patch of the series.

The second patch is more cleanup; is slightly touches OVS code, so that
list is in CC this time, too.

As in v1, the last two patches actually make VXLAN over IPv6 link-local
work, and allow multiple VXLANs with the same VNI and port, as long as
link-local addresses on different interfaces are used. As suggested, I now
store in the flags field if the VXLAN uses link-local addresses or not.

v3 removes log messages as suggested by Roopa Prabhu (as it is very unusual
for errors in netlink requests to be printed to the kernel log.) The commit
message of patch 5 has been extended to add a note about IPv4.

Matthias Schiffer (6):
  vxlan: refactor verification and application of configuration
  vxlan: get rid of redundant vxlan_dev.flags
  vxlan: improve validation of address family configuration
  vxlan: check valid combinations of address scopes
  vxlan: fix snooping for link-local IPv6 addresses
  vxlan: allow multiple VXLANs with same VNI for IPv6 link-local
    addresses

 drivers/net/vxlan.c           | 412 +++++++++++++++++++++++++-----------------
 include/net/vxlan.h           |   3 +-
 net/openvswitch/vport-vxlan.c |   4 +-
 3 files changed, 255 insertions(+), 164 deletions(-)

-- 
2.13.1
