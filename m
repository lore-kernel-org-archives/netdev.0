From: Tony Zelenoff <antonz@parallels.com>
Subject: [PATCH 0/9] atl1: add napi to Atheros L1 NIC
Date: Fri, 13 Apr 2012 20:09:45 +0400
Message-ID: <1334333394-38404-1-git-send-email-antonz@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <antonz@parallels.com>, <netdev@vger.kernel.org>,
	<jcliburn@gmail.com>, <csnook@redhat.com>, <khorenko@parallels.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.parallels.com ([195.214.232.42]:54696 "EHLO
	relay.parallels.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754215Ab2DMQJ7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Apr 2012 12:09:59 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Added NAPI interface to the driver of Atheros L1 NIC.
RX speed reported by iperf in TCP mode (with and without -N
switch) improved by ~7 Mbps. In UDP mode the speed up is
improved by ~4 Mbps.
Also hard RX/TX rings processing with memory allocation in
interrupt handlers is not very good idea. So, fixed this.

Note: thouse patches must be applied after patch, that fix
kernel panic in this driver.
Its subject is: "atl1: fix kernel panic in case of DMA errors"

Tony Zelenoff (9):
  atl1: handle rx in separate condition
  atl1: make driver napi compatible
  atl1: add napi process of tx interrupts
  atl1: use defined functions to disable irq
  atl1: make function to set imr of card
  atl1: add value to check ability of reenabling IRQs
  atl1: enable errors and link ints when rx/tx scheduled
  atl1: do not process interrupts in cycle in handler
  atl1: do not drop rx/tx interrupts before they are scheduled

 drivers/net/ethernet/atheros/atlx/atl1.c |  171 +++++++++++++++++++-----------
 drivers/net/ethernet/atheros/atlx/atl1.h |   17 +++-
 drivers/net/ethernet/atheros/atlx/atlx.c |   15 ++-
 3 files changed, 135 insertions(+), 68 deletions(-)
