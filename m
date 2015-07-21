From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/9] sfc: support for cascaded multicast filtering
Date: Tue, 21 Jul 2015 15:07:44 +0100
Message-ID: <55AE5230.3040605@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo01.seg.att.com ([209.65.160.76]:44184 "EHLO
	nbfkord-smmo01.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932094AbbGUOQn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jul 2015 10:16:43 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recent versions of firmware for SFC9100 adapters add support for filter
 chaining, in which packets matching multiple filters are delivered to all
 filters' recipients, rather than only the highest match-priority filter as was
 previously the case.
This patch series enables this feature and redesigns the filter handling code
 to make use of it; in particular, subscribing to a multicast address on one
 function no longer prevents traffic to that address reaching another function
 which is in promiscuous or allmulti mode.
If the firmware does not support filter chaining, the driver will fall back to
 the old behaviour.

Daniel Pieczko (5):
  sfc: enable cascaded multicast filters in MCFW
  sfc: add output flag decoding to efx_mcdi_set_workaround
  sfc: warn if other functions have been reset by MCFW
  sfc: re-factor efx_ef10_filter_sync_rx_mode()
  sfc: support cascaded multicast filters

Edward Cree (3):
  sfc: update MCDI protocol definitions
  sfc: cope with ENOSYS from efx_mcdi_get_workarounds()
  sfc: clean fallbacks between promisc/normal in
    efx_ef10_filter_sync_rx_mode

Jon Cooper (1):
  sfc: Insert multicast filters as well as mismatch filters in
    promiscuous mode

 drivers/net/ethernet/sfc/ef10.c       |  495 +++--
 drivers/net/ethernet/sfc/mcdi.c       |   28 +-
 drivers/net/ethernet/sfc/mcdi.h       |    3 +-
 drivers/net/ethernet/sfc/mcdi_pcol.h  | 3463 +++++++++++++++++++++++++--------
 drivers/net/ethernet/sfc/net_driver.h |    2 +
 drivers/net/ethernet/sfc/nic.h        |    2 +
 6 files changed, 2997 insertions(+), 996 deletions(-)
