From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net v3 0/2] sfc: Restrict PIO for 64bit arch in order to avoid
 data corruption
Date: Thu, 29 May 2014 11:18:44 +0100
Message-ID: <53870984.6020803@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:29103 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752220AbaE2KSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 May 2014 06:18:50 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series 
Fixes: ee45fd92c739("sfc: Use TX PIO for sufficiently small packets")

The linux net driver uses memcpy_toio() in order to copy into
the PIO buffers.
Even on a 64bit machine this causes 32bit accesses to a write-
combined memory region.
There are hardware limitations that mean that only
64bit naturally aligned accesses are safe in all cases. Due to being
write-combined memory region two 32bit accesses may be coalesced to
form a 64bit non 64bit aligned access.
Solution was to open-code the memory copy routines using pointers
and to only enable PIO for x86_64 machines.

This bug fix applies to v3.13 and v3.14 stable branches.

Jon Cooper (2):
  sfc: use 64-bit writes for PIO.
  sfc: Restrict PIO to 64-bit architectures

 drivers/net/ethernet/sfc/io.h |  8 ++++++++
 drivers/net/ethernet/sfc/tx.c | 24 +++++++++++++++++++-----
 2 files changed, 27 insertions(+), 5 deletions(-)
