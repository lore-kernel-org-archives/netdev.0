From: Thomas F Herbert <thomasfherbert@gmail.com>
Subject: [PATCH net-next V15 0/3] openvswitch: Add support for 802.1ad
Date: Sat, 10 Oct 2015 19:40:30 -0400
Message-ID: <1444520433-1958-1-git-send-email-thomasfherbert@gmail.com>
Cc: therbert@redhat.com, dev@openvswitch.org,
	Thomas F Herbert <thomasfherbert@gmail.com>
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f173.google.com ([209.85.212.173]:36459 "EHLO
	mail-wi0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009AbbJJXkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Oct 2015 19:40:51 -0400
Received: by wicgb1 with SMTP id gb1so109550502wic.1
        for <netdev@vger.kernel.org>; Sat, 10 Oct 2015 16:40:50 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Thomas F Herbert (3):
  openvswitch: 802.1ad uapi changes.
  Check for vlan ethernet types for 8021.q or 802.1ad
  802.1AD: Flow handling, actions, vlan parsing and netlink attributes

 include/linux/if_vlan.h          |  17 ++++
 include/uapi/linux/openvswitch.h |  17 ++--
 net/openvswitch/actions.c        |   6 +-
 net/openvswitch/flow.c           |  92 ++++++++++++++++++----
 net/openvswitch/flow.h           |  11 ++-
 net/openvswitch/flow_netlink.c   | 166 +++++++++++++++++++++++++++++++++++----
 net/openvswitch/vport-netdev.c   |   4 +-
 7 files changed, 271 insertions(+), 42 deletions(-)

This patch accompanies version 14 of the user level openvswitch patch
submitted to openvswitch dev list.

V15: Implement reviewer comments.

V14: Add outer tpid to flow_key

V13: Fix incorrect encoding and decoding of netlink to/from key
attributes.

V12: Fix some problems and issues pointed out by reviewers. When parsing
netlink attributes Ether types other then 0x88a8 as outer tpid.

V11: Add inner tpid to flow key. Fix separate inner encap attribute
when parsing netlink attributes. Merge 2 patches to consolidate
qinq changes.

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


For discussion, history  and previous versions of the kernel module
patch and the user code patch see the OVS dev mailing list,
openvswitch.org/pipermail/dev/..

-- 
2.4.3
