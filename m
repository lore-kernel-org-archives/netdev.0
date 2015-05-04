From: Alexander Duyck <alexander.h.duyck@redhat.com>
Subject: [net-next PATCH 0/5] Add eth_proto_is_802_3 to provide improved
 means of checking Ethertype
Date: Mon, 04 May 2015 14:33:42 -0700
Message-ID: <20150504212603.2536.29877.stgit@ahduyck-vm-fedora22>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, pshelar@nicira.com, davem@davemloft.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbbEDVds (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 May 2015 17:33:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series implements and makes use of eth_proto_is_802_3().  The
idea behind the function is to provide an optimized means of testing to
determine if a given Ethertype value is a length or 802.3 protocol number.
The standard path for this was to use ntohs(proto) and then perform a
comparison.  This adds a slight cost as it usually requires either a 16b
rotate or byte swap which can cost 1 cycle or more depending on the
processor.

I had previously addressed this for eth_type_trans, however in doing so I had
overlooked checking with sparse and had introduced a couple sparse warnings.
The first patch in this series fixes those sparse warnings as well as does
some additional optimization for big endian systems.  In addition it pushes
the code out into a separate function which can then be used in the other
patches to reduce the instruction count/processing time in those functions
as well.

---

Alexander Duyck (5):
      etherdev: Fix sparse error, make test usable by other functions
      ebtables: Use eth_proto_is_802_3
      ipv4/ip_tunnel_core: Use eth_proto_is_802_3
      openvswitch: Use eth_proto_is_802_3
      vlan: Use eth_proto_is_802_3


 include/linux/etherdevice.h     |   18 ++++++++++++++++++
 include/linux/if_vlan.h         |    2 +-
 net/bridge/netfilter/ebtables.c |    2 +-
 net/ethernet/eth.c              |    2 +-
 net/ipv4/ip_tunnel_core.c       |    2 +-
 net/openvswitch/datapath.c      |    2 +-
 net/openvswitch/flow.c          |    4 ++--
 net/openvswitch/flow_netlink.c  |    2 +-
 8 files changed, 26 insertions(+), 8 deletions(-)

--
