From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 0/7] OVS conntrack fixes for net
Date: Thu,  1 Oct 2015 13:53:23 -0700
Message-ID: <1443732810-38746-1-git-send-email-joestringer@nicira.com>
Cc: linux-kernel@vger.kernel.org, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

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

---
v2: Address minor style feedback, add acks.
v1: Initial post.

Joe Stringer (7):
  openvswitch: Rename LABEL->LABELS
  openvswitch: Fix typos in CT headers
  openvswitch: Fix skb leak in ovs_fragment()
  openvswitch: Ensure flow is valid before executing ct
  openvswitch: Reject ct_state unsupported bits
  openvswitch: Extend ct_state match field to 32 bits
  openvswitch: Change CT_ATTR_FLAGS to CT_ATTR_COMMIT

 include/uapi/linux/openvswitch.h | 36 +++++++---------
 net/openvswitch/actions.c        | 19 ++++++---
 net/openvswitch/conntrack.c      | 89 ++++++++++++++++++++--------------------
 net/openvswitch/conntrack.h      | 12 ++++++
 net/openvswitch/flow.h           |  2 +-
 net/openvswitch/flow_netlink.c   | 30 ++++++++------
 6 files changed, 104 insertions(+), 84 deletions(-)

-- 
2.1.4
