From: Troy Kisky <troy.kisky@boundarydevices.com>
Subject: [PATCH net-next V3 00/16] net: fec: cleanup and fixes
Date: Tue,  5 Apr 2016 19:25:46 -0700
Message-ID: <1459909562-22865-1-git-send-email-troy.kisky@boundarydevices.com>
Cc: fabio.estevam@nxp.com, l.stach@pengutronix.de, andrew@lunn.ch,
	tremyfr@gmail.com, gerg@uclinux.org,
	linux-arm-kernel@lists.infradead.org, johannes@sipsolutions.net,
	stillcompiling@gmail.com, sergei.shtylyov@cogentembedded.com,
	arnd@arndb.de, Troy Kisky <troy.kisky@boundarydevices.com>
To: netdev@vger.kernel.org, davem@davemloft.net, fugang.duan@nxp.com,
	lznuaa@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:35311 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752745AbcDFC2J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 22:28:09 -0400
Received: by mail-pa0-f47.google.com with SMTP id td3so22727719pab.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 19:28:09 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V3 has

1 dropped patch "net: fec: print more debug info in fec_timeout"
2 new patches
0002-net-fec-remove-unused-interrupt-FEC_ENET_TS_TIMER.patch
0003-net-fec-return-IRQ_HANDLED-if-fec_ptp_check_pps_even.patch

1 combined patch
0004-net-fec-pass-rxq-txq-to-fec_enet_rx-tx_queue-instead.patch

The changes are noted on individual patches

My measured performance of this series is

before patch set
365 Mbits/sec Tx/407 RX

after patch set
374 Tx/427 Rx


Troy Kisky (16):
  net: fec: only check queue 0 if RXF_0/TXF_0 interrupt is set
  net: fec: remove unused interrupt FEC_ENET_TS_TIMER
  net: fec: return IRQ_HANDLED if fec_ptp_check_pps_event handled it
  net: fec: pass rxq/txq to fec_enet_rx/tx_queue instead of queue_id
  net: fec: reduce interrupts
  net: fec: split off napi routine with 3 queues
  net: fec: don't clear all rx queue bits when just one is being checked
  net: fec: set cbd_sc without relying on previous value
  net: fec: eliminate calls to fec_enet_get_prevdesc
  net: fec: move restart test for efficiency
  net: fec: clear cbd_sc after transmission to help with debugging
  net: fec: dump all tx queues in fec_dump
  net: fec: detect tx int lost
  net: fec: create subroutine reset_tx_queue
  net: fec: call dma_unmap_single on mapped tx buffers at restart
  net: fec: don't set cbd_bufaddr unless no mapping error

 drivers/net/ethernet/freescale/fec.h      |  10 +-
 drivers/net/ethernet/freescale/fec_main.c | 410 ++++++++++++++++--------------
 2 files changed, 218 insertions(+), 202 deletions(-)

-- 
2.5.0
