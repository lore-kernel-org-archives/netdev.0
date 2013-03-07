From: "Nithin Nayak Sujir" <nsujir@broadcom.com>
Subject: [PATCH net-next 0/6] Add support to download EEE firmware for
 the 57766
Date: Wed, 6 Mar 2013 19:02:28 -0800
Message-ID: <1362625354-15095-1-git-send-email-nsujir@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "Nithin Nayak Sujir" <nsujir@broadcom.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms1.broadcom.com ([216.31.210.17]:4281 "EHLO mms1.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752713Ab3CGDDR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Mar 2013 22:03:17 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

For the 57766 devices with no NVRAM, there is not enough space for the complete
boot code with EEE support. On these devices, the tg3 driver has to download
a service patch firmware to the scratchpad for the boot code to execute. This
patchset adds support to do the above.

A major portion of this patchset is refactoring the existing firmware download
section to allow a cleaner merge of the 57766 download. The 57766 firmware
differs from previous firmware in that it's not written to a contiguous area in
memory. It consists of multiple fragments to be written to different locations.
The patchset makes an attempt to make the new firmware format to be an
extension of the existing format.


Matt Carlson (1):
  tg3: Add new FW_TSO flag

Nithin Nayak Sujir (5):
  tg3: Refactor cpu pause/resume code
  tg3: Refactor the 2nd type of cpu pause
  tg3: Cleanup firmware parsing code
  tg3: Enhance firmware download code to support fragmented firmware
  tg3: Download 57766 EEE service patch firmware

 drivers/net/ethernet/broadcom/tg3.c | 378 ++++++++++++++++++++++++++----------
 drivers/net/ethernet/broadcom/tg3.h |  18 +-
 2 files changed, 288 insertions(+), 108 deletions(-)

-- 
1.8.1.4
