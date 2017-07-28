From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next v3 0/7] netvsc: minor fixes and optimization
Date: Fri, 28 Jul 2017 08:59:40 -0700
Message-ID: <20170728155947.10062-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f51.google.com ([74.125.83.51]:35678 "EHLO
        mail-pg0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751633AbdG1P7u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Jul 2017 11:59:50 -0400
Received: by mail-pg0-f51.google.com with SMTP id v190so112840104pgv.2
        for <netdev@vger.kernel.org>; Fri, 28 Jul 2017 08:59:49 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a subset of earlier submission with a few more fixes
found during testing. The are two small optimizations, one is to
better manage the receive completion ring, and the other is removing
one unneeded level of indirection.

Will submit the improved VF support and buffer sizing in a later
patch so they get more review.

Stephen Hemminger (7):
  netvsc: fix return value for set_channels
  netvsc: fix warnings reported by lockdep
  netvsc: don't print pointer value in error message
  netvsc: remove unnecessary indirection of page_buffer
  netvsc: optimize receive completions
  netvsc: fix error unwind on device setup failure
  netvsc: signal host if receive ring is emptied

 drivers/net/hyperv/hyperv_net.h   |  19 +--
 drivers/net/hyperv/netvsc.c       | 302 ++++++++++++++++----------------------
 drivers/net/hyperv/netvsc_drv.c   |  27 ++--
 drivers/net/hyperv/rndis_filter.c | 108 +++++++-------
 4 files changed, 208 insertions(+), 248 deletions(-)

-- 
2.11.0
