From: Matthias Schiffer <mschiffer@universe-factory.net>
Subject: [PATCH net-next 0/3] VXLAN over IPv6 link-local
Date: Fri, 10 Mar 2017 23:39:41 +0100
Message-ID: <cover.1489184335.git.mschiffer@universe-factory.net>
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: davem@davemloft.net, jbenc@redhat.com, hannes@stressinduktion.org,
        pshelar@ovn.org, aduyck@mirantis.com, roopa@cumulusnetworks.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from chaos.universe-factory.net ([37.72.148.22]:41702 "EHLO
        chaos.universe-factory.net" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S932711AbdCJWko (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Mar 2017 17:40:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Running VXLANs over IPv6 link-local addresses allows to use them as a
drop-in replacement for VLANs, avoiding to allocate additional outer IP
addresses to run the VXLAN over.

The first patch is basically a bugfix, not allowing to use link-local
addresses without specifying an interface; it doesn't seem important enough
for net/stable though (and without the second patch, allowing to specify
link-local addresses at all does not result in a working configuration
anyways). The second patch then actually makes VXLAN over link-local IPv6
work by passing interface indices at the right places.

The final patch lifts the limitation of not allowing multiple VXLANs with
the same VNI and port, as long as link-local IPv6 addresses are used and
different interfaces are specified. Again, this brings VXLAN a bit closer
to VLANs feature-wise.


Matthias Schiffer (3):
  vxlan: don't allow link-local IPv6 local/remote addresses without
    interface
  vxlan: fix snooping for link-local IPv6 addresses
  vxlan: allow multiple VXLANs with same VNI for IPv6 link-local
    addresses

 drivers/net/vxlan.c | 120 +++++++++++++++++++++++++++++++++++++---------------
 1 file changed, 87 insertions(+), 33 deletions(-)
