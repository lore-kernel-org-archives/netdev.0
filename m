From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 00/15] netvsc: misc patches
Date: Wed,  3 May 2017 16:01:02 -0700
Message-ID: <20170503230117.20070-1-sthemmin@microsoft.com>
Cc: netdev@vger.kernel.org, Stephen Hemminger <sthemmin@microsoft.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:33762 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751198AbdECXBV (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 3 May 2017 19:01:21 -0400
Received: by mail-pg0-f45.google.com with SMTP id y4so1996038pge.0
        for <netdev@vger.kernel.org>; Wed, 03 May 2017 16:01:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mostly these are performance related. There is also one bug fix for
incorrect handling of NAPI on device removal

Stephen Hemminger (15):
  vmbus: simplify hv_ringbuffer_read
  vmbus: fix unnecessary signal events as result of NAPI
  netvsc: make sure napi enabled before vmbus_open
  netvsc: don't reacquire rtnl on device removal
  netvsc: optimize avail percent calculation
  netvsc: prefetch the first incoming ring element
  netvsc: convert ring_size to unsigned
  netvsc: allow overriding send/recv buffer size
  netvsc: optimize netvsc_send_pkt
  netvsc: replace modulus with mask for alignment
  netvsc: reduce unnecessary memset
  netvsc: size receive completion ring based on receive area
  netvsc: convert open count from atomic to refcount
  netvsc: optimize receive completions
  netvsc: use vzalloc_node for receive completion data

 drivers/hv/ring_buffer.c          | 179 +++++++++---------------
 drivers/net/hyperv/hyperv_net.h   |  32 +++--
 drivers/net/hyperv/netvsc.c       | 282 +++++++++++++++++---------------------
 drivers/net/hyperv/netvsc_drv.c   |  56 ++++++--
 drivers/net/hyperv/rndis_filter.c |  20 +--
 include/linux/hyperv.h            |  70 +---------
 6 files changed, 266 insertions(+), 373 deletions(-)

-- 
2.11.0
