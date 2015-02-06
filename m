From: Sathya Perla <sathya.perla@emulex.com>
Subject: [PATCH net-next 0/9] be2net: patch set
Date: Fri, 6 Feb 2015 08:18:34 -0500
Message-ID: <1423228723-10919-1-git-send-email-sathya.perla@emulex.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cmexedge2.emulex.com ([138.239.224.100]:28175 "EHLO
	CMEXEDGE2.ext.emulex.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754467AbbBFNPi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Feb 2015 08:15:38 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave, pls consider applying the following patch-set to the
net-next tree. It has 5 code/style cleanup patches and 4 patches that
add functionality to the driver.

Patch 1 moves routines that were not needed to be in be.h to the respective
src files, to avoid unnecessary compilation.

Patch 2 replaces (1 << x) with BIT(x) macro

Patch 3 refactors code that checks if a FW flash file is compatible
with the adapter. The code is now refactored into 2 routines, the first one
gets the file type from the image file and the 2nd routine checks if the
file type is compatible with the adapter.

Patch 4 adds compatibility checks for flashing a FW image on the new
Skyhawk P2 HW revision.

Patch 5 adds support for a new "offset based" flashing scheme, wherein
the driver informs the FW of the offset at which each component in the flash
file is to be flashed at. This helps flashing components that were 
previously not recognized by the running FW.

Patch 6 simplifies the be_cmd_rx_filter() routine, by passing to it the
filter flags already used in the FW cmd, instead of the netdev flags that
were converted to the FW-cmd flags. 

Patch 7 introduces helper routines in be_set_rx_mode() and be_vid_config()
to improve code readability.

Patch 8 adds processing of port-misconfig async event sent by the FW.

Patch 9 removes unnecessary swapping of a field in the TX desc.

Sathya Perla (4):
  be2net: move un-exported routines from be.h to respective src files
  be2net: remove duplicate code in be_cmd_rx_filter()
  be2net: refactor be_set_rx_mode() and be_vid_config() for readability
  be2net: avoid unncessary swapping of fields in eth_tx_wrb

Vasundhara Volam (5):
  be2net: replace (1 << x) with BIT(x)
  be2net: refactor code that checks flash file compatibility
  be2net: avoid flashing SH-B0 UFI image on SH-P2 chip
  be2net: use offset based FW flashing for Skyhawk chip
  be2net: process port misconfig async event

 drivers/net/ethernet/emulex/benet/be.h      | 199 +--------
 drivers/net/ethernet/emulex/benet/be_cmds.c | 209 ++++++---
 drivers/net/ethernet/emulex/benet/be_cmds.h |  43 +-
 drivers/net/ethernet/emulex/benet/be_hw.h   |  14 +-
 drivers/net/ethernet/emulex/benet/be_main.c | 635 +++++++++++++++++++---------
 5 files changed, 647 insertions(+), 453 deletions(-)

-- 
2.2.0
