From: Julien Fortin <julien@cumulusnetworks.com>
Subject: [PATCH 00/27] ip: add -json support to 'ip link show'
Date: Thu,  3 Aug 2017 17:54:48 +0200
Message-ID: <20170803155515.99226-1-julien@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: roopa@cumulusnetworks.com, nikolay@cumulusnetworks.com,
        dsa@cumulusnetworks.com, Julien Fortin <julien@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f180.google.com ([209.85.128.180]:37940 "EHLO
        mail-wr0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751143AbdHCPza (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 11:55:30 -0400
Received: by mail-wr0-f180.google.com with SMTP id f21so7354173wrf.5
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 08:55:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julien Fortin <julien@cumulusnetworks.com>

This patch series adds json support to 'ip [-details] link show [dev DEV]'
Each patch describes the json schema it adds and provides some examples.

Julien Fortin (27):
  color: add new COLOR_NONE and disable_color function
  ip: add new command line argument -json (mutually exclusive with
    -color)
  json_writer: add new json handlers (null, float with format, lluint,
    hu)
  ip: ip_print: add new API to print JSON or regular format output
  ip: ipaddress.c: add support for json output
  ip: iplink.c: open/close json object for ip -brief -json link show dev
    DEV
  ip: iplink_bond.c: add json output support
  ip: iplink_bond_slave.c: add json output support (info_slave_data)
  ip: iplink_hsr.c: add json output support
  ip: iplink_bridge.c: add json output support
  ip: iplink_bridge_slave.c: add json output support
  ip: iplink_can.c: add json output support
  ip: iplink_geneve.c: add json output support
  ip: iplink_ipoib.c: add json output support
  ip: iplink_ipvlan.c: add json output support
  ip: iplink_vrf.c: add json output support
  ip: iplink_vxlan.c: add json output support
  ip: iplink_xdp.c: add json output support
  ip: ipmacsec.c: add json output support
  ip: link_gre.c: add json output support
  ip: link_gre6.c: add json output support
  ip: link_ip6tnl.c: add json output support
  ip: link_iptnl.c: add json output support
  ip: link_vti.c: add json output support
  ip: link_vti6.c: add json output support
  ip: link_macvlan.c: add json output support
  ip: iplink_vlan.c: add json output support

 include/color.h          |    2 +
 include/json_writer.h    |    9 +
 include/utils.h          |    1 +
 ip/Makefile              |    2 +-
 ip/ip.c                  |    6 +
 ip/ip_common.h           |   56 +++
 ip/ip_print.c            |  233 ++++++++++
 ip/ipaddress.c           | 1089 ++++++++++++++++++++++++++++++++--------------
 ip/iplink.c              |    2 +
 ip/iplink_bond.c         |  231 +++++++---
 ip/iplink_bond_slave.c   |   57 ++-
 ip/iplink_bridge.c       |  291 ++++++++-----
 ip/iplink_bridge_slave.c |  185 +++++---
 ip/iplink_can.c          |  276 +++++++++---
 ip/iplink_geneve.c       |   86 +++-
 ip/iplink_hsr.c          |   36 +-
 ip/iplink_ipoib.c        |   30 +-
 ip/iplink_ipvlan.c       |    8 +-
 ip/iplink_macvlan.c      |   37 +-
 ip/iplink_vlan.c         |   62 ++-
 ip/iplink_vrf.c          |   13 +-
 ip/iplink_vxlan.c        |  161 ++++---
 ip/iplink_xdp.c          |   31 +-
 ip/ipmacsec.c            |   84 +++-
 ip/link_gre.c            |  147 ++++---
 ip/link_gre6.c           |  142 ++++--
 ip/link_ip6tnl.c         |  172 +++++---
 ip/link_iptnl.c          |  155 ++++---
 ip/link_vti.c            |   23 +-
 ip/link_vti6.c           |   22 +-
 lib/color.c              |    9 +-
 lib/json_writer.c        |   44 +-
 32 files changed, 2668 insertions(+), 1034 deletions(-)
 create mode 100644 ip/ip_print.c

-- 
2.13.3
