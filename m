From: Andy Zhou <azhou@ovn.org>
Subject: [net-next sample action optimization v3 0/4]
Date: Thu, 16 Mar 2017 15:48:26 -0700
Message-ID: <1489704510-35975-1-git-send-email-azhou@ovn.org>
Cc: joe@ovn.org, pshelar@ovn.org, Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:34287 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753997AbdCPW6V (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 16 Mar 2017 18:58:21 -0400
Received: by mail-pg0-f67.google.com with SMTP id b5so7548611pgg.1
        for <netdev@vger.kernel.org>; Thu, 16 Mar 2017 15:58:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sample action can be used for translating Openflow 'clone' action.
However its implementation has not been sufficiently optimized for this
use case. This series attempts to close the gap.

Patch 3 commit message has more details on the specific optimizations
implemented.

---
v1->v2: Address pravin's comment, Refactor recirc and sample
        to share more common code

v2->v3: Enhace patch 4, add more loigc to the common code

Andy Zhou (4):
  openvswitch: Deferred fifo API change.
  openvswitch: Refactor recirc key allocation.
  openvswitch: Optimize sample action for the clone use cases
  Openvswitch: Refactor sample and recirc actions implementation

 include/uapi/linux/openvswitch.h |  15 +++
 net/openvswitch/actions.c        | 270 ++++++++++++++++++++++-----------------
 net/openvswitch/datapath.h       |   2 -
 net/openvswitch/flow_netlink.c   | 141 +++++++++++++-------
 4 files changed, 262 insertions(+), 166 deletions(-)

-- 
1.8.3.1
