From: =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
Subject: [PATCHv2 0/5] sh_eth: add wake-on-lan support via magic packet
Date: Mon, 12 Dec 2016 17:09:26 +0100
Message-ID: <20161212160931.6478-1-niklas.soderlund+renesas@ragnatech.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
        =?UTF-8?q?Niklas=20S=C3=B6derlund?=
        <niklas.soderlund+renesas@ragnatech.se>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Simon Horman <horms+renesas@verge.net.au>,
        netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-4.sys.kth.se ([130.237.48.193]:54183 "EHLO
        smtp-4.sys.kth.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752905AbcLLQK0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 12 Dec 2016 11:10:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

This series adds support for Wake-on-Lan using Magic Packet for a few 
models of the sh_eth driver. Patch 1/5 adds generic support to control 
and support WoL while patches 2/5 - 5/5 enable different models.

Changes since v1.
- Spit generic WoL functionality and device enablement to different 
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

Niklas Söderlund (5):
  sh_eth: add generic wake-on-lan support via magic packet
  sh_eth: enable wake-on-lan for Gen2 devices
  sh_eth: enable wake-on-lan for r8a7740/armadillo
  sh_eth: enable wake-on-lan for sh7743
  sh_eth: enable wake-on-lan for sh7763

 drivers/net/ethernet/renesas/sh_eth.c | 121 +++++++++++++++++++++++++++++++---
 drivers/net/ethernet/renesas/sh_eth.h |   3 +
 2 files changed, 114 insertions(+), 10 deletions(-)

-- 
2.10.2
