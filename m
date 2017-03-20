From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v4 0/4]
Date: Mon, 20 Mar 2017 16:32:26 -0700
Message-ID: <1490052750-60187-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35744 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753279AbdCTXl2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 20 Mar 2017 19:41:28 -0400
Received: by mail-pf0-f195.google.com with SMTP id n11so8079193pfg.2
        for <netdev@vger.kernel.org>; Mon, 20 Mar 2017 16:40:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample action can be used for translating Openflow 'clone' action.
However its implementation has not been sufficiently optimized for this
use case. This series attempts to close the gap.

Patch 3 commit message has more details on the specific optimizations
implemented.

---
v3->v4: Enhance patch 4.
        Fix two bugs pointed out by Pravin,
        Remove 'is_sample' variable.

v2->v3: Enhance patch 4, Rafctor to move more common logic to clone_execute().

v1->v2: Address Pravin's comment, Refactor recirc and sample
        to share more common code

Andy Zhou (4):
openvswitch: Deferred fifo API change.
openvswitch: Refactor recirc key allocation.
openvswitch: Optimize sample action for the clone use cases
Openvswitch: Refactor sample and recirc actions implementation

 include/uapi/linux/openvswitch.h |  15 +++
 net/openvswitch/actions.c        | 271 ++++++++++++++++++++++-----------------
 net/openvswitch/datapath.h       |   2 -
 net/openvswitch/flow_netlink.c   | 141 +++++++++++++-------
 4 files changed, 263 insertions(+), 166 deletions(-)

-- 
1.8.3.1
