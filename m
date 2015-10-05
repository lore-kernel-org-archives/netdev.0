From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv3 net 0/6] OVS conntrack fixes for net
Date: Mon,  5 Oct 2015 15:23:13 -0700
Message-ID: <1444083799-57090-1-git-send-email-joestringer@nicira.com>
Cc: davem@davemloft.net, pshelar@nicira.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:32786 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751487AbbJEWX0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Oct 2015 18:23:26 -0400
Received: by pacex6 with SMTP id ex6so188867024pac.0
        for <netdev@vger.kernel.org>; Mon, 05 Oct 2015 15:23:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The userspace side of the Open vSwitch conntrack changes is currently
undergoing review, which has highlighted some minor bugs in the existing
conntrack implementation in the kernel, as well as pointing out some
future-proofing that can be done on the interface to reduce the need for
additional compatibility code in future.

The biggest changes here are to the userspace API for the ct_state match
field and the CT action. This series proposes to firstly extend the ct_state
match field to 32 bits, ensuring to reject any currently unsupported bits.
Secondly, rather than representing CT action flags within a 32-bit field,
simply use a netlink attribute as presence of the single flag that is
defined today. This also serves to reject unsupported ct action flag bits.

Joe Stringer (6):
  openvswitch: Fix typos in CT headers
  openvswitch: Fix skb leak in ovs_fragment()
  openvswitch: Ensure flow is valid before executing ct
  openvswitch: Reject ct_state unsupported bits
  openvswitch: Extend ct_state match field to 32 bits
  openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT

 include/uapi/linux/openvswitch.h | 24 +++++++++---------------
 net/openvswitch/actions.c        | 17 +++++++++++++----
 net/openvswitch/conntrack.c      | 15 +++++++--------
 net/openvswitch/conntrack.h      | 12 ++++++++++++
 net/openvswitch/flow_netlink.c   | 12 +++++++++---
 5 files changed, 50 insertions(+), 30 deletions(-)

-- 
2.1.4
