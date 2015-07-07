From: Shradha Shah <sshah@solarflare.com>
Subject: [PATCH net 0/3] sfc: compat for lack of VADAPTOR_SET_MAC in adaptor_firmware
 <= 4.1.1.1023
Date: Tue, 7 Jul 2015 11:35:18 +0100
Message-ID: <559BAB66.1080905@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, <linux-net-drivers@solarflare.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo03.seg.att.com ([209.65.160.84]:48036 "EHLO
	nbfkord-smmo03.seg.att.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751072AbbGGKfZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Jul 2015 06:35:25 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series resolves an incompatibility with legacy
firmware due to the lack of MC_CMD_VADAPTOR_SET_MAC in
adaptor_firmware <= 4.1.1.1023

Unless this patch series is applied there will be a compatibility
issue between the driver and Solarflare adapters running older
firmware. 

Tested with and without CONFIG_SFC_SRIOV

Daniel Pieczko (3):
  sfc: refactor code in efx_ef10_set_mac_address()
  sfc: add legacy method for changing a PF's MAC address
  sfc: suppress handled MCDI failures when changing the MAC address

 drivers/net/ethernet/sfc/ef10.c       | 172 ++++++++++++++++++++++++++++------
 drivers/net/ethernet/sfc/ef10_sriov.c |  42 ---------
 drivers/net/ethernet/sfc/ef10_sriov.h |   6 ++
 3 files changed, 151 insertions(+), 69 deletions(-)
