From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net 0/7] OVS conntrack fixes for net
Date: Tue, 29 Sep 2015 15:39:33 -0700
Message-ID: <1443566380-22640-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:35938 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751101AbbI2WkA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Sep 2015 18:40:00 -0400
Received: by pablk4 with SMTP id lk4so18017329pab.3
        for <netdev@vger.kernel.org>; Tue, 29 Sep 2015 15:40:00 -0700 (PDT)
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

Joe Stringer (7):
  openvswitch: Make LABELS name more consistent
  openvswitch: Fix typos in CT headers
  openvswitch: Fix skb leak in ovs_fragment()
  openvswitch: Ensure flow is valid before executing ct
  openvswitch: Reject ct_state unsupported bits
  openvswitch: Extend ct_state match field to 32 bits
  openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT

 include/uapi/linux/openvswitch.h | 28 +++++++++++-----------------
 net/openvswitch/actions.c        | 21 ++++++++++++++++-----
 net/openvswitch/conntrack.c      | 32 +++++++++++++++++++-------------
 net/openvswitch/conntrack.h      | 12 ++++++++++++
 net/openvswitch/flow_netlink.c   | 26 ++++++++++++++++----------
 5 files changed, 74 insertions(+), 45 deletions(-)

-- 
2.1.4
