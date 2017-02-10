From: Shannon Nelson <shannon.nelson@oracle.com>
Subject: [PATCH v3 net-next 0/9] sunvnet driver updates
Date: Fri, 10 Feb 2017 09:38:16 -0800
Message-ID: <1486748305-240339-1-git-send-email-shannon.nelson@oracle.com>
Cc: sparclinux@vger.kernel.org, linux-kernel@vger.kernel.org,
        Shannon Nelson <shannon.nelson@oracle.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:23131 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751913AbdBJRpK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 12:45:10 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The sunvnet ldom virtual network driver was due for some updates and
a bugfix or two.  These patches address a few items left over from
last year's make-over.

v2:
 - changed memory barrier fix to use smp_wmb
 - put NETIF_F_SG back into the advertised ldmvsw hw_features

v3:
 - the sunvnet_common module doesn't need module_init or _exit

Shannon Nelson (8):
  sunvnet: make sunvnet common code dynamically loadable
  sunvnet: update version and version printing
  sunvnet: add driver stats for ethtool support
  sunvnet: add memory barrier before check for tx enable
  sunvnet: straighten up message event handling logic
  sunvnet: remove extra rcu_read_unlocks
  ldmvsw: update and simplify version string
  ldmvsw: disable tso and gso for bridge operations

Sowmini Varadhan (1):
  sunvnet: remove unused variable in maybe_tx_wakeup

 drivers/net/ethernet/sun/Kconfig          |    8 ++-
 drivers/net/ethernet/sun/ldmvsw.c         |   82 +++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet.c        |   77 ++++++++++++++++---
 drivers/net/ethernet/sun/sunvnet_common.c |  119 ++++++++++++++---------------
 4 files changed, 200 insertions(+), 86 deletions(-)
