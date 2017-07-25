From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 0/5] netvsc: fixes and performance related changes
Date: Tue, 25 Jul 2017 13:04:17 -0700
Message-ID: <20170725200422.13795-1-sthemmin@microsoft.com>
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com, haiyangz@microsoft.com, sthemmin@microsoft.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35842 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753562AbdGYUEZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Jul 2017 16:04:25 -0400
Received: by mail-pf0-f169.google.com with SMTP id z129so22712522pfb.3
        for <netdev@vger.kernel.org>; Tue, 25 Jul 2017 13:04:25 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The first two are more fixes to problems introduced in
latest net-next changes.  The rest are changes to improve performance
and reduce memory footprint.  The driver used to allocate large
amounts of memory (33M) per interface, this reduces that down to
about 7M.

Stephen Hemminger (5):
  netvsc: fix return value for set_channels
  netvsc: fix warnings reported by lockdep
  netvsc: optimize receive completions
  netvsc: signal host if receive ring is emptied
  netvsc: allow smaller send/recv buffer size

 drivers/net/hyperv/hyperv_net.h   |  24 ++--
 drivers/net/hyperv/netvsc.c       | 293 ++++++++++++++++----------------------
 drivers/net/hyperv/netvsc_drv.c   |  48 ++++++-
 drivers/net/hyperv/rndis_filter.c | 104 +++++++-------
 4 files changed, 228 insertions(+), 241 deletions(-)

-- 
2.11.0
