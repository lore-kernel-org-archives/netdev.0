From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/8] netvsc: lockdep and related fixes
Date: Wed, 19 Jul 2017 11:53:11 -0700
Message-ID: <20170719185319.25871-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:34962 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752847AbdGSSxW (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 19 Jul 2017 14:53:22 -0400
Received: by mail-pg0-f45.google.com with SMTP id v190so3932498pgv.2
        for <netdev@vger.kernel.org>; Wed, 19 Jul 2017 11:53:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

These fix sparse and lockdep warnings from netvsc driver.
Targeting these at net-next since no actual related failures
have been observed in non-debug kernels.

Stephen Hemminger (8):
  netvsc: force link update after MTU change
  netvsc: add some rtnl_dereference annotations
  netvsc: change order of steps in setting queues
  netvsc: change logic for change mtu and set_queues
  netvsc: use ERR_PTR to avoid dereference issues
  netvsc: need rcu_derefence when accessing internal device info
  netvsc: save pointer to parent netvsc_device in channel table
  netvsc: add rtnl annotations in rndis

 drivers/net/hyperv/hyperv_net.h   | 26 +++++-------
 drivers/net/hyperv/netvsc.c       | 33 ++++++++++------
 drivers/net/hyperv/netvsc_drv.c   | 83 +++++++++++++++++++++------------------
 drivers/net/hyperv/rndis_filter.c | 62 ++++++++++++++++-------------
 4 files changed, 107 insertions(+), 97 deletions(-)

-- 
2.11.0
