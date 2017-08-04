From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net 0/1] netvsc: race on sub channel open
Date: Thu,  3 Aug 2017 17:13:53 -0700
Message-ID: <20170804001354.17067-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f172.google.com ([209.85.192.172]:33986 "EHLO
        mail-pf0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751866AbdHDAN6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 3 Aug 2017 20:13:58 -0400
Received: by mail-pf0-f172.google.com with SMTP id o86so1093589pfj.1
        for <netdev@vger.kernel.org>; Thu, 03 Aug 2017 17:13:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Found this while testing mtu, queue and buffer size changes
in 4.13, but the problem goes back much further. The addition
of NAPI makes the race into a crash. Before that there was just
a risk of sending on an uninitialized channel.

Stephen Hemminger (1):
  netvsc: fix race on sub channel creation

 drivers/net/hyperv/hyperv_net.h   |  3 ++-
 drivers/net/hyperv/netvsc.c       |  1 +
 drivers/net/hyperv/rndis_filter.c | 14 ++++++++------
 3 files changed, 11 insertions(+), 7 deletions(-)

-- 
2.11.0
