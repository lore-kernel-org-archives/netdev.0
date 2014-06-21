From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: [RFT 0/3] cxgb4: use request_firmware_nowait()
Date: Fri, 20 Jun 2014 17:39:38 -0700
Message-ID: <1403311181-9328-1-git-send-email-mcgrof@do-not-panic.com>
Cc: poswald@suse.com, santosh@chelsio.com, jcheung@suse.com,
	dchang@suse.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, mcgrof@suse.com
To: hariprasad@chelsio.com, leedom@chelsio.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "Luis R. Rodriguez" <mcgrof@suse.com>

Its reported that loading the cxgb4 can take over 1 minute,
use the more sane request_firmware_nowait() API call just
in case this amount of time is causing issues. The driver
uses the firmware API 3 times, one for the firmware, one
for configuration and another one for flash, this provides
the port for all cases.

I don't have the hardware so please test. I did verify we
can use this during pci probe and also during the ethtool
flash callback.

Luis R. Rodriguez (3):
  cxgb4: make ethtool set_flash use request_firmware_nowait()
  cxgb4: make configuration load use request_firmware_nowait()
  cxgb4: make device firmware load use request_firmware_nowait()

 drivers/net/ethernet/chelsio/cxgb4/cxgb4.h      |  13 ++
 drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c | 258 +++++++++++++++---------
 2 files changed, 176 insertions(+), 95 deletions(-)

-- 
2.0.0
