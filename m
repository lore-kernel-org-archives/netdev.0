From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V10 0/4] openvswitch: Add support for 802.1AD
Date: Tue,  2 Jun 2015 13:50:40 -0400
Message-ID: <1433267444-26025-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yh0-f51.google.com ([209.85.213.51]:35785 "EHLO
	mail-yh0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759547AbbFBRvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2015 13:51:04 -0400
Received: by yhda23 with SMTP id a23so43421667yhd.2
        for <netdev@vger.kernel.org>; Tue, 02 Jun 2015 10:51:03 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for 802.1AD to the openvswitch kernel module.

V10: Implement reviewer comments: Consolidate vlan parsing functions.
Splits netlink parsing and flow conversion into a separate patch. Uses
double encap attribute encapsulation for 802.1ad.  Netlink attributes
now look like this:

    eth_type(0x88a8),vlan(vid=100),encap(eth_type(0x8100), vlan(vid=200),
        encap(eth_type(0x0800), ...))

The double encap atributes in this version of the patch is incompatible with
old versions of the user level 802.1ad patch. A new user level patch which 
is also being submitted simultaneously to openvswitch dev mailing list.

V9:  Includes changes suggested by reviewers

V8:  Includes changes suggested by reviewers

V7:  Includes changes suggested by reviewers

V6:  Rebased to net-next

V5:  Use encapsulated attributes

Although the Open Flow specification specified support for 802.1AD (qinq)
as well as push and pop vlan headers,  So far Open vSwitch has only
supported a single tag header.

This patch accompanies version 10 of the user level openvswitch patch 
submitted to openvswitch dev list.
For discussion, history  and previous versions of the kernel module 
patch and the user code patch see the OVS dev mailing list, 
openvswitch.org/pipermail/dev/..

Thomas F Herbert (4):
  openvswitch: 802.1ad uapi changes.
  Check for vlan ethernet types for 8021.q or 802.1ad
  8021AD: Flow handling actions and parsing
  8021AD: Flow key parsing and netlink attributes.

 include/linux/if_vlan.h          |   9 ++
 include/uapi/linux/openvswitch.h |  17 ++--
 net/openvswitch/flow.c           |  82 ++++++++++++++---
 net/openvswitch/flow.h           |   3 +
 net/openvswitch/flow_netlink.c   | 186 +++++++++++++++++++++++++++++++++------
 5 files changed, 248 insertions(+), 49 deletions(-)

-- 
2.1.0
