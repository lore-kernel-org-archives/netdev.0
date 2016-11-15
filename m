From: Tobias Regnery <tobias.regnery@gmail.com>
Subject: [PATCH net-next V2 0/9] alx: add multi queue support
Date: Tue, 15 Nov 2016 12:43:07 +0100
Message-ID: <cover.1479208627.git.tobias.regnery@gmail.com>
Cc: davem@davemloft.net, Tobias Regnery <tobias.regnery@gmail.com>
To: netdev@vger.kernel.org, jcliburn@gmail.com, chris.snook@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35702 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751359AbcKOLna (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Nov 2016 06:43:30 -0500
Received: by mail-wm0-f67.google.com with SMTP id a20so24979597wme.2
        for <netdev@vger.kernel.org>; Tue, 15 Nov 2016 03:43:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset lays the groundwork for multi queue support in the alx driver
and enables multi queue support for the tx path by default. The hardware
supports up to 4 tx queues. 

Benefits are better utilization of multi core cpus and the usage of the
msi-x support by default which splits the handling of rx / tx and misc
other interrupts.

The rx path is a little bit harder because apparently (based on the limited
information from the downstream driver) the hardware supports up to 8 rss
queues but only has one hardware descriptor ring on the rx side. So the rx
path will be part of another patchset.

Tested on my AR8161 ethernet adapter with different tests:
- there are no regressions observed during my daily usage
- iperf tcp and udp tests shows no performance regressions
- netperf TCP_RR and UDP_RR shows a slight performance increase of about
  1-2% with this patchset applied

This work is based on the downstream driver at github.com/qca/alx

Changes in V2:
	- drop unneeded casts in alx_alloc_rx_ring (Patch 1)
	- add additional information about testing and benefit to the
	  changelog

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
