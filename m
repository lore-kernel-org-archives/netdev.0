From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 0/2] sfc: Restrict PIO for 64bit arch in order to avoid
 data corruption
Date: Tue, 20 May 2014 08:44:45 +0100
Message-ID: <537B07ED.4080104@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	linux-net-drivers <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:11038 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750703AbaETHou convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 May 2014 03:44:50 -0400
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


The information contained in this message is confidential and is intended for the addressee(s) only. If you have received this message in error, please notify the sender immediately and delete the message. Unless you are an addressee (or authorized to receive for an addressee), you may not use, copy or disclose to anyone this message or any information contained in this message. The unauthorized use, disclosure, copying or alteration of this message is strictly prohibited.
