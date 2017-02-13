From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/2] sfc: prevent bogus interrupt-mode fallbacks
Date: Mon, 13 Feb 2017 14:54:56 +0000
Message-ID: <2af4ea1f-cdf7-48b2-1712-e25590919f15@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:17072 "EHLO
        nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1751867AbdBMOzF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 13 Feb 2017 09:55:05 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

EF10 VFs only support MSI-X interrupts, not MSI or legacy.  This series
 stops the probe logic from trying to fallback to those if MSI-X interrupt
 probe fails.  It also prevents selecting them with the interrupt_mode
 module parameter.
This avoids producing messages like "failed to hook legacy IRQ 0" and "IRQ
 handler type mismatch for IRQ 0", and ensures that the relevant error
 (from the attempt to enable MSI-X) is reported to the caller.

Andrew Rybchenko (2):
  sfc: MSI-X is the only interrupt mode for EF10 VFs
  sfc: only fall back to a lower interrupt mode if it is supported

 drivers/net/ethernet/sfc/ef10.c       |  2 ++
 drivers/net/ethernet/sfc/efx.c        | 21 +++++++++++++++++----
 drivers/net/ethernet/sfc/net_driver.h |  5 ++++-
 drivers/net/ethernet/sfc/siena.c      |  1 +
 4 files changed, 24 insertions(+), 5 deletions(-)
