From: Roopa Prabhu <roopa@cumulusnetworks.com>
Subject: [PATCH iproute2 net-next 0/2] bridge: support for vlan to tunnel mapping
Date: Thu, 26 Oct 2017 12:16:05 -0700
Message-ID: <1509045367-42793-1-git-send-email-roopa@cumulusnetworks.com>
Cc: netdev@vger.kernel.org, nikolay@cumulusnetworks.com
To: stephen@networkplumber.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f193.google.com ([209.85.192.193]:48048 "EHLO
        mail-pf0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932404AbdJZTQR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2017 15:16:17 -0400
Received: by mail-pf0-f193.google.com with SMTP id z11so3199044pfk.4
        for <netdev@vger.kernel.org>; Thu, 26 Oct 2017 12:16:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds the required options to iplink and bridge commands
to enable per vlan tunnel info on a bridge port provided by
netlink attributes IFLA_BRPORT_VLAN_TUNNEL (flag) and
IFLA_BRIDGE_VLAN_TUNNEL_INFO

enable vlan-tunnel mapping on a bridge port:
$ip link set dev vxlan0 type bridge_slave vlan_tunnel on
$ip link set dev vxlan0 type bridge_slave vlan_tunnel off

or

$bridge link set dev vxlan0 vlan_tunnel on
$bridge link set dev vxlan0 vlan_tunnel off

add vlan tunnel mapping (expects vlans to have been already
configured on the port):
$bridge vlan add dev vxlan0 vid 2000 tunnel_info id 2000
$bridge vlan add dev vxlan0 vid 1000-1001 tunnel_info id 2000-2001

$bridge vlan tunnelshow
port    vlan ids        tunnel id
vxlan0   1000-1001       1000-1001
         2000            2000

$bridge  -j vlan tunnelshow
{
    "dummy0": [],
    "dummy1": [],
    "bridge": [],
    "vxlan0": [{
            "vlan": 1000,
            "vlanEnd": 1001,
            "tunid": 1000,
            "tunidEnd": 1001
        },{
            "vlan": 2000,
            "tunid": 2000
        }
    ]
}

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>

Roopa Prabhu (2):
  iplink: bridge: support bridge port vlan_tunnel attribute
  bridge: vlan: support for per vlan tunnel info

 bridge/link.c            |  12 ++
 bridge/vlan.c            | 305 ++++++++++++++++++++++++++++++++++++++++++-----
 ip/iplink_bridge_slave.c |   9 ++
 man/man8/bridge.8        |  12 +-
 man/man8/ip-link.8.in    |   5 +
 5 files changed, 315 insertions(+), 28 deletions(-)

-- 
2.1.4
