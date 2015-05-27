From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next v4 0/3] sfc: add MCDI tracing
Date: Wed, 27 May 2015 13:12:31 +0100
Message-ID: <5565B4AF.50603@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:57403 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751015AbbE0MMj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 May 2015 08:12:39 -0400
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
v4: remove patch #4, which has already been applied via sshah
v3: add some explanations to cover letter and patch #4
v2: avoid long lines in cover letter; fix multiline comment style

Edward Cree (3):
  sfc: add tracing of MCDI commands
  sfc: add sysfs entry to control MCDI tracing
  sfc: add module parameter to enable MCDI logging on new functions

 drivers/net/ethernet/sfc/Kconfig |   9 ++++
 drivers/net/ethernet/sfc/ef10.c  |   3 ++
 drivers/net/ethernet/sfc/efx.c   |  49 ++++++++++++++++---
 drivers/net/ethernet/sfc/mcdi.c  | 100 +++++++++++++++++++++++++++++++++++++--
 drivers/net/ethernet/sfc/mcdi.h  |   6 +++
 5 files changed, 156 insertions(+), 11 deletions(-)
