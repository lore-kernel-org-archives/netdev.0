From: Edward Cree <ecree@solarflare.com>
Subject: [PATCH net-next 0/6] sfc: more encap offloads
Date: Wed, 8 Feb 2017 16:49:12 +0000
Message-ID: <b4d116f2-8298-60c4-7f33-f53d9f39a9cd@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: <linux-net-drivers@solarflare.com>, <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbfkord-smmo02.seg.att.com ([209.65.160.78]:60703 "EHLO
        nbfkord-smmo02.seg.att.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1752056AbdBHQze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:55:34 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series adds support for RX checksum offload of encapsulated packets.
It also adds support for configuring the hardware's lists of UDP ports used for
VXLAN and GENEVE encapsulation offloads.  Since changing these lists causes the
MC to reboot, the driver has been hardened against reboots, which used to be
considered an exceptional occurrence but are now normal.

Jon Cooper (5):
  sfc: process RX event inner checksum flags
  sfc: set csum_level for encapsulated packets
  sfc: harden driver against MC resets during initial probe
  sfc: call mcdi_reboot_detected() when MC reboots during an MCDI
    command
  sfc: configure UDP tunnel offload ports

Matthew Slattery (1):
  sfc: update mcdi_pcol definitions for
    MC_CMD_SET_TUNNEL_ENCAP_UDP_PORTS

 drivers/net/ethernet/sfc/bitfield.h   |   3 +
 drivers/net/ethernet/sfc/ef10.c       | 429 +++++++++++++++++++++++++++++++++-
 drivers/net/ethernet/sfc/efx.c        | 171 +++++++++++---
 drivers/net/ethernet/sfc/ethtool.c    |   5 +
 drivers/net/ethernet/sfc/mcdi.c       |  15 +-
 drivers/net/ethernet/sfc/mcdi.h       |   1 +
 drivers/net/ethernet/sfc/mcdi_pcol.h  |  21 ++
 drivers/net/ethernet/sfc/net_driver.h |  39 +++-
 drivers/net/ethernet/sfc/nic.h        |   7 +
 drivers/net/ethernet/sfc/rx.c         |   5 +-
 drivers/net/ethernet/sfc/siena.c      |   2 +
 11 files changed, 640 insertions(+), 58 deletions(-)
