From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: [PATCH v3 0/1] net/macb: add TX multiqueue support for gem
Date: Fri, 12 Dec 2014 13:26:43 +0100
Message-ID: <cover.1418383702.git.cyrille.pitchen@atmel.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <linux-kernel@vger.kernel.org>,
	Cyrille Pitchen <cyrille.pitchen@atmel.com>
To: <nicolas.ferre@atmel.com>, <davem@davemloft.net>,
	<linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	<soren.brinkmann@xilinx.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ChangeLog

v3:
- reduce the number of added #define in macb.h
- simplify the queue initialization
- add some more comments
- use "hw_q" index when dealing with the hardware queue mask and "q" index for
  linux (software) queue index in "for" loops

v2:
fix compilation warnings for netdev_vdbg("%u...", queue - bp->queues, ...) calls

v1:
At the first look this patch may look quite big but it cannot be splitted.
Each queue has its own dedicated IRQ, which should be handled.
Also the Transmit Base Queue Pointer register of each available queue must be
initialized before starting the transmission, otherwise the transmission will be
halted immediately as HRESP errors are likely to occur.
In addition, some fields had to be moved from struct macb into struct macb_queue
so a common code could manage the queues.

This patch was applied to net-next and tested on a sama5d36ek board, which embeds
both macb and gem IPs, to check the backward compatibility.

Also it was tested on a sama5dx FPGA platform with a gem designed to use 3 queues.
Then we used the tc program to set a queue discipline policy as describe in the
Documentation/networking/multiqueue.txt: we successfully used each queue.

Cyrille Pitchen (1):
  net/macb: add TX multiqueue support for gem

 drivers/net/ethernet/cadence/macb.c | 456 +++++++++++++++++++++++-------------
 drivers/net/ethernet/cadence/macb.h |  36 ++-
 2 files changed, 328 insertions(+), 164 deletions(-)

-- 
1.8.2.2
