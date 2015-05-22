From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next v3 0/4] sfc: add MCDI tracing
Date: Fri, 22 May 2015 20:19:25 +0100
Message-ID: <555F813D.8000108@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:62432 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756674AbbEVTTp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 22 May 2015 15:19:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patchset adds support for logging MCDI (Management-Controller-to-
 Driver Interface) interactions between the sfc driver and a bound device,
 to aid in debugging.
Solarflare has a tool to decode the resulting traces and will look to
 open-source this if there is any external interest, but the protocol is
 already detailed in drivers/net/ethernet/sfc/mcdi_pcol.h.
The logging buffer we allocate per MCDI context is a work area for
 constructing each individual message before logging it with netif_info.
The reason the buffer is long-lived is simply to avoid the overhead of
 allocating and freeing it every MCDI call, since MCDIs are already known
 to be serialised for other reasons.

--
v3: add some explanations to cover letter and patch #4
v2: avoid long lines in cover letter; fix multiline comment style

Edward Cree (3):
  sfc: add tracing of MCDI commands
  sfc: add sysfs entry to control MCDI tracing
  sfc: add module parameter to enable MCDI logging on new functions

Jon Cooper (1):
  sfc: Initialise MCDI buffers to 0 on declaration.

 drivers/net/ethernet/sfc/Kconfig |   9 ++++
 drivers/net/ethernet/sfc/ef10.c  |  27 ++++++----
 drivers/net/ethernet/sfc/efx.c   |  49 +++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.c  | 108 ++++++++++++++++++++++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.h  |  14 +++--
 drivers/net/ethernet/sfc/ptp.c   |   6 +--
 6 files changed, 181 insertions(+), 32 deletions(-)
