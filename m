From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net v2 0/2] sfc: Restrict PIO for 64bit arch in order to avoid
 data corruption
Date: Wed, 28 May 2014 10:23:01 +0100
Message-ID: <5385AAF5.7090001@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-net-drivers@solarflare.com>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:17040 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752133AbaE1JXH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 May 2014 05:23:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series 
Fixes: ee45fd92c739db5b7950163d91dfe5f016af6d24

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
