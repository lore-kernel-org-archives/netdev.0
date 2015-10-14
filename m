From: Ronen Arad <ronen.arad@intel.com>
Subject: [PATCH net-next 0/4] Rightsize IFLA_AF_SPEC size calculation
Date: Tue, 13 Oct 2015 22:58:30 -0700
Message-ID: <1444802314-28830-1-git-send-email-ronen.arad@intel.com>
Cc: Ronen Arad <ronen.arad@intel.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:64742 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750857AbbJNF7C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2015 01:59:02 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

if_nlmsg_size() overestimates the minimum allocation size of netlink dump
request (when called from rtnl_calcit()) or the size of the message (when called
from rtnl_getlink()). This is because ext_filter_mask is not supported by
rtnl_link_get_af_size() and rtnl_link_get_size().

The over-estimation is significant when at least one netdev has many VLANs
configured (8 bytes for each configured VLAN).

This patch-set "rightsizes" the protocol specific attribute size calculation by
propagating ext_filter_mask to rtnl_link_get_af_size() and adding optional
filtering aware get_af_size_filtered op in struct rtnl_af_ops. Bridge module,
which already used filtering aware sizing for notification, is enhanced to do
the same for netlink dump requests.

Ronen Arad (4):
  rtnetlink: Add get_link_af_size_filtered to rtnl_af_ops
  bridge: br_af_ops add br_get_link_af_size_filtered
  rtnetlink: Prefer filtering-aware af sizing
  bridge: Remove br_get_link_af_size

 include/net/rtnetlink.h |  2 ++
 net/bridge/br_netlink.c | 23 ++---------------------
 net/core/rtnetlink.c    | 12 +++++++++---
 3 files changed, 13 insertions(+), 24 deletions(-)

--
2.1.0
