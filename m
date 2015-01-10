From: roopa@cumulusnetworks.com
Subject: [PATCH net-next v3 0/4] bridge: support for vlan range in setlink/dellink
Date: Sat, 10 Jan 2015 07:31:11 -0800
Message-ID: <1420903874-25528-1-git-send-email-roopa@cumulusnetworks.com>
Cc: wkok@cumulusnetworks.com, sfeldma@gmail.com
To: netdev@vger.kernel.org, shemminger@vyatta.com, vyasevic@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f46.google.com ([209.85.213.46]:37394 "EHLO
	mail-yh0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753995AbbAJPbV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Jan 2015 10:31:21 -0500
Received: by mail-yh0-f46.google.com with SMTP id t59so6515611yho.5
        for <netdev@vger.kernel.org>; Sat, 10 Jan 2015 07:31:20 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Roopa Prabhu <roopa@cumulusnetworks.com>

This series adds new flags in IFLA_BRIDGE_VLAN_INFO to indicate
vlan range.

Will post corresponding iproute2 patches if these get accepted.

v1-> v2
    - changed patches to use a nested list attribute
    IFLA_BRIDGE_VLAN_INFO_LIST as suggested by scott feldman
    - dropped notification changes from the series. Will post them
    separately after this range message is accepted.

v2 -> v3
    - incorporated some review feedback
    - include patches to fill vlan ranges during getlink
    - Dropped IFLA_BRIDGE_VLAN_INFO_LIST. I think it may get
    confusing to userspace if we introduce yet another way to
    send lists. With getlink already sending nested
    IFLA_BRIDGE_VLAN_INFO in IFLA_AF_SPEC, It seems better to
    use the existing format for lists and just use the flags from v2
    to mark vlan ranges

Signed-off-by: Roopa Prabhu <roopa@cumulusnetworks.com>
Signed-off-by: Wilson Kok <wkok@cumulusnetworks.com>

Roopa Prabhu (4):
  bridge: new flags to represent vlan info ranges
  bridge: add support to parse multiple vlan info attributes in
    IFLA_AF_SPEC
  rtnetlink: new filter RTEXT_FILTER_BRVLAN_COMPRESSED
  bridge: new function to pack vlans into ranges during gets

 include/uapi/linux/if_bridge.h |    2 +
 include/uapi/linux/rtnetlink.h |    1 +
 net/bridge/br_netlink.c        |  243 +++++++++++++++++++++++++++++++---------
 3 files changed, 195 insertions(+), 51 deletions(-)

-- 
1.7.10.4
