From: Joe Stringer <joestringer@nicira.com>
Subject: [RFC net-next 0/4] OVS conntrack support
Date: Sat, 14 Feb 2015 00:13:49 -0800
Message-ID: <1423901633-53789-1-git-send-email-joestringer@nicira.com>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	Justin Pettit <jpettit@nicira.com>,
	Thomas Graf <tgraf@suug.ch>, dev@openvswitch.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from na3sys009aog123.obsmtp.com ([74.125.149.149]:43954 "HELO
	na3sys009aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1753519AbbBNIN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2015 03:13:59 -0500
Received: by mail-ie0-f179.google.com with SMTP id rl12so22226529iec.4
        for <netdev@vger.kernel.org>; Sat, 14 Feb 2015 00:13:58 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is the latest in a series of RFCs for allowing OVS to send packets through
the Linux kernel connection tracker, and subsequently match on fields populated
by conntrack.

As for outstanding comments from previous versions:
- IP frag is not yet addressed. These packets are passed directly to conntrack
  without reassembly.
- If there are other comments that I have missed, please re-raise them as they
  have likely fallen off my radar.

The latest userspace code is available below. It has an initial test in the
"check-kernel" suite to test allowing all traffic in one direction and only
replies in the other direction. I plan to extend these to test "related" using
the ftp conntrack module, and check matching on conn fields. The branch does
not have support for matching connection state invalid yet.

https://github.com/justinpettit/ovs/tree/conntrack

Changes with this series:
- Rebase to net-next.
- Add conn_zone field to the flow key.
- Refactor conntrack changes into net/openvswitch/ovs_conntrack.*.
- Don't allow set_field() actions to change conn_state, conn_zone.
- Add OVS_CS_F_* flags to indicate connection state for OVS userspace
  abstraction.
- Add "invalid" connection state, which is set if conntrack fails to identify
  the connection..

Joe Stringer (2):
  openvswitch: Serialize acts with original netlink len.
  openvswitch: Move MASKED* macros to datapath.h.

Justin Pettit (2):
  openvswitch: Add conntrack action.
  openvswitch: Allow matching on conntrack mark.

 include/uapi/linux/openvswitch.h |   37 ++++
 net/openvswitch/Kconfig          |   11 ++
 net/openvswitch/Makefile         |    1 +
 net/openvswitch/actions.c        |   62 ++++---
 net/openvswitch/conntrack.c      |  368 ++++++++++++++++++++++++++++++++++++++
 net/openvswitch/conntrack.h      |   85 +++++++++
 net/openvswitch/datapath.c       |   20 ++-
 net/openvswitch/datapath.h       |    4 +
 net/openvswitch/flow.c           |    4 +
 net/openvswitch/flow.h           |    4 +
 net/openvswitch/flow_netlink.c   |   92 ++++++++--
 net/openvswitch/flow_netlink.h   |    4 +-
 12 files changed, 641 insertions(+), 51 deletions(-)
 create mode 100644 net/openvswitch/conntrack.c
 create mode 100644 net/openvswitch/conntrack.h

-- 
1.7.10.4
