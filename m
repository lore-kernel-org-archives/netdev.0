From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next 0/9] alx: add multi queue support
Date: Fri, 21 Oct 2016 12:49:43 +0200
Message-ID: <cover.1477044917.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: jcliburn@gmail.com, chris.snook@gmail.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f196.google.com ([209.85.220.196]:36620 "EHLO
        mail-qk0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754035AbcJUKuK (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2016 06:50:10 -0400
Received: by mail-qk0-f196.google.com with SMTP id z190so6734392qkc.3
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2016 03:50:10 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset lays the groundwork for multi queue support in the alx driver
and enables multi queue support for the tx path by default. The hardware
supports up to 4 tx queues. 

The rx path is a little bit harder because apparently (based on the limited
information from the downstream driver) the hardware supports up to 8 rss
queues but only has one hardware descriptor ring on the rx side. So the rx
path will be part of another patchset.

This work is based on the downstream driver at github.com/qca/alx

I had a hard time splitting these changes up into reasonable parts because
this is my first bigger kernel patchset, so please be patient if this is not
the right approach.

Tobias Regnery (9):
  alx: refactor descriptor allocation
  alx: extend data structures for multi queue support
  alx: add ability to allocate and free alx_napi structures
  alx: switch to per queue data structures
  alx: prepare interrupt functions for multiple queues
  alx: prepare resource allocation for multi queue support
  alx: prepare tx path for multi queue support
  alx: enable msi-x interrupts by default
  alx: enable multiple tx queues

 drivers/net/ethernet/atheros/alx/alx.h  |  36 ++-
 drivers/net/ethernet/atheros/alx/main.c | 554 ++++++++++++++++++++++----------
 2 files changed, 420 insertions(+), 170 deletions(-)

-- 
2.7.4
