From: Richard Cochran <richardcochran@gmail.com>
Subject: [PATCH 00/11] net: expand time stamping, batch #2
Date: Sun, 19 Jun 2011 13:19:56 +0200
Message-ID: <cover.1308481491.git.richard.cochran@omicron.at>
Cc: David Miller <davem@davemloft.net>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:44082 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753431Ab1FSLUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2011 07:20:03 -0400
Received: by fxm17 with SMTP id 17so448603fxm.19
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2011 04:20:01 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch series represents a continuation of the effort to get
better coverage of the SO_TIMESTAMPING socket API in the Ethernet
drivers.  Adding time stamping support to a given driver solves two
separate issues, namely software transmit time stamping and hardware
time stamping in PHY devices.

This second batch adds the hooks into all remaining (?) arm and
powerpc MAC drivers using phylib. The first patch exports the receive
hook for use by non-NAPI drivers when compiled as modules. Patch #5
has been tested on real hardware, but the rest have only been compile
tested.

Richard Cochran (11):
  net: export the receive time stamping hook for non-NAPI drivers
  lib8390: enable transmit and receive time stamping.
  emaclite: enable transmit and receive time stamping.
  ll_temac: enable transmit and receive time stamping.
  fec_mpc52xx: enable transmit and receive time stamping.
  macb: enable transmit time stamping.
  fs_enet: enable transmit time stamping.
  smsc911x: enable transmit time stamping.
  pxa168_eth: enable transmit time stamping.
  mv643xx_eth: enable transmit time stamping.
  ucc_geth: enable transmit time stamping.

 drivers/net/fec_mpc52xx.c          |    4 +++-
 drivers/net/fs_enet/fs_enet-main.c |    2 ++
 drivers/net/lib8390.c              |    5 +++--
 drivers/net/ll_temac_main.c        |    5 ++++-
 drivers/net/macb.c                 |    2 ++
 drivers/net/mv643xx_eth.c          |    2 ++
 drivers/net/pxa168_eth.c           |    1 +
 drivers/net/smsc911x.c             |    1 +
 drivers/net/ucc_geth.c             |    1 +
 drivers/net/xilinx_emaclite.c      |    9 +++++++--
 net/core/timestamping.c            |    1 +
 11 files changed, 27 insertions(+), 6 deletions(-)

