From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 0/2] vxlan: support both IPv4 and IPv6 sockets
Date: Thu, 24 Sep 2015 13:50:00 +0200
Message-ID: <cover.1443094736.git.jbenc@redhat.com>
Cc: Thomas Graf <tgraf@suug.ch>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51237 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbbIXLuP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Sep 2015 07:50:15 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Note: this needs net merged into net-next in order to apply.

It's currently not easy enough to work with metadata based vxlan tunnels. In
particular, it's necessary to create separate network interfaces for IPv4
and IPv6 tunneling. Assigning an IPv6 address to an IPv4 interface is
allowed yet won't do what's expected. With route based tunneling, one has to
pay attention to use the vxlan interface opened with the correct family.
Other users of this (openvswitch) would need to always create two vxlan
interfaces.

Furthermore, there's no sane API for creating an IPv6 vxlan metadata based
interface.

This patchset simplifies this by opening both IPv4 and IPv6 socket if the
vxlan interface has the metadata flag (IFLA_VXLAN_COLLECT_METADATA) set.
Assignment of addresses etc. works as expected after this.

Jiri Benc (2):
  vxlan: make vxlan_sock_add and vxlan_sock_release complementary
  vxlan: support both IPv4 and IPv6 sockets in a single vxlan device

 drivers/net/vxlan.c           | 167 +++++++++++++++++++++++++++---------------
 include/net/vxlan.h           |  14 +++-
 net/openvswitch/vport-vxlan.c |   3 +-
 3 files changed, 121 insertions(+), 63 deletions(-)

-- 
1.8.3.1
