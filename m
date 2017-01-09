From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv3 0/6] sh_eth: add wake-on-lan support via magic packet
Date: Mon,  9 Jan 2017 16:34:03 +0100
Message-ID: <20170109153409.13956-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        linux-pm@vger.kernel.org,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:52233 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S934162AbdAIPfM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Jan 2017 10:35:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds support for Wake-on-Lan using Magic Packet for a few
models of the sh_eth driver. Patch 1/6 fix a naming error, patch 2/6 
adds generic support to control and support WoL while patches 3/6 - 6/6 
enable different models.

Based ontop of net-next master.

Changes since v2.
- Fix bookkeeping for "active_count" and "event_count" reported in 
  /sys/kernel/debug/wakeup_sources. Thanks Geert for noticing this.
- Add new patch 1/6 which corrects the name of ECMR_MPDE bit, suggested 
  by Sergei.
- s/sh7743/sh7734/ in patch 5/6. Thanks Geert for spotting this.
- Spelling improvements suggested by Sergei and Geert.
- Add Tested-by to 3/6 and 4/6.

Changes since v1.
- Split generic WoL functionality and device enablement to different
  patches.
- Enable more devices then Gen2 after feedback from Geert and
  datasheets.
- Do not set mdp->irq_enabled = false and remove specific MagicPacket
  interrupt clearing, instead let sh_eth_error() clear the interrupt as
  for other EMAC interrupts, thanks Sergei for the suggestion.
- Use the original return logic in sh_eth_resume().
- Moved sh_eth_private variable *clk to top of data structure  to avoid
  possible gaps due to alignment restrictions.
- Make wol_enabled in sh_eth_private part of the already existing
  bitfield instead of a bool.
- Do not initiate mdp->wol_enabled to 0, the struct is kzalloc'ed so
  it's already set to 0.

Niklas Söderlund (6):
  sh_eth: use correct name for ECMR_MPDE bit
  sh_eth: add generic wake-on-lan support via magic packet
  sh_eth: enable wake-on-lan for R-Car Gen2 devices
  sh_eth: enable wake-on-lan for r8a7740/armadillo
  sh_eth: enable wake-on-lan for sh7734
  sh_eth: enable wake-on-lan for sh7763

 drivers/net/ethernet/renesas/sh_eth.c | 123 +++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   5 +-
 2 files changed, 117 insertions(+), 11 deletions(-)

-- 
2.11.0
