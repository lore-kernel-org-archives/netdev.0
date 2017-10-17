From: Andy Zhou <azhou@ovn.org>
Subject: [net-next v2 0/4] Openvswitch meter action
Date: Tue, 17 Oct 2017 00:36:41 -0700
Message-ID: <1508225805-11613-1-git-send-email-azhou@ovn.org>
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 8bit
Cc: pshelar@ovn.org, joe@ovn.org, gvrose8192@gmail.com,
        Andy Zhou <azhou@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:45177 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759056AbdJQHiC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2017 03:38:02 -0400
Received: by mail-pg0-f66.google.com with SMTP id b192so769474pga.2
        for <netdev@vger.kernel.org>; Tue, 17 Oct 2017 00:38:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series is the first attempt to add openvswitch
meter support. We have previously experimented with adding
metering support in nftables. However 1) It was not clear
how to expose a named nftables object cleanly, and 2)
the logic that implements metering is quite small, < 100 lines
of code.

With those two observations, it seems cleaner to add meter
support in the openvswitch module directly.

---
    v1(RFC)->v2:  remove unused code
                  improve locking
                  and other review comments

Andy Zhou (4):
  openvswitch: Add meter netlink definitions
  openvswitch: export get_dp() API.
  openvswitch: Add meter infrastructure
  openvswitch: Add meter action support

 include/uapi/linux/openvswitch.h |  54 ++++
 net/openvswitch/Makefile         |   1 +
 net/openvswitch/actions.c        |   6 +
 net/openvswitch/datapath.c       |  43 +--
 net/openvswitch/datapath.h       |  35 +++
 net/openvswitch/flow_netlink.c   |   6 +
 net/openvswitch/meter.c          | 604 +++++++++++++++++++++++++++++++++++++++
 net/openvswitch/meter.h          |  54 ++++
 8 files changed, 772 insertions(+), 31 deletions(-)
 create mode 100644 net/openvswitch/meter.c
 create mode 100644 net/openvswitch/meter.h

-- 
1.8.3.1
