From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: [PATCH 0/3 v2 net-next] enic: add vxlan offload support
Date: Wed,  8 Feb 2017 16:43:06 -0800
Message-ID: <20170209004309.1225-1-gvaradar@cisco.com>
Cc: benve@cisco.com, Govindarajulu Varadarajan <gvaradar@cisco.com>
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcdn-iport-4.cisco.com ([173.37.86.75]:21646 "EHLO
        rcdn-iport-4.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751812AbdBIBY6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 20:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This series adds vxlan offload support for enic driver. The first
patch adds vxlan devcmd for configuring vxland offload parameters.
Second patch adds ndo_udp_tunnel_add/del and offload on rx path.
There are to modes in which fw supports vxlan offload.

mode 0: fcoe bit is set for encapsulated packet. fcoe_fc_crc_ok is set
if checksum of csum is ok. This bit is or of ip_csum_ok and
tcp_udp_csum_ok

mode 2: BIT(0) in rss_hash is set if it is encapsulated packet.
        BIT(1) is set if outer_ip_csum_ok/
        BIT(2) is set if outer_tcp_csum_ok

Some hw supports only mode 0, some support mode 0 and 2. Driver gets
the supported modes bitmap using get_supported_feature_ver devcmd
and selects the highest mode both driver and fw supports.

Third patch adds offload support on tx path by adding
enic_features_check().

v2: Order local variable declarations from longest to shortest line,
    on all three patches.

Govindarajulu Varadarajan (3):
  enic: add devcmds for vxlan offload
  enic: add udp_tunnel ndo for vxlan offload
  enic: add vxlan offload on tx path

 drivers/net/ethernet/cisco/enic/enic.h        |   6 +
 drivers/net/ethernet/cisco/enic/enic_main.c   | 282 ++++++++++++++++++++++++--
 drivers/net/ethernet/cisco/enic/vnic_dev.c    |  34 ++++
 drivers/net/ethernet/cisco/enic/vnic_dev.h    |   5 +
 drivers/net/ethernet/cisco/enic/vnic_devcmd.h |  51 +++++
 drivers/net/ethernet/cisco/enic/vnic_enet.h   |   1 +
 6 files changed, 364 insertions(+), 15 deletions(-)

-- 
2.11.0
