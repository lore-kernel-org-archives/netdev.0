From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH ] ethtool: Remove duplex info from CTRL register dump
Date: Wed, 11 Jan 2006 23:16:42 -0800
Message-ID: <20060112071642.29428.23880.stgit@Gecko.tarbal.com>
Cc: John Ronciak <john.ronciak@intel.com>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030276AbWALHQr@vger.kernel.org>
To: Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The duplex control register is used for setting the driver and is not
necessary for debug purposes.  The value of the duplex control register is
what the register's current value is and may not reflect the correct status
of te current connection.  That is what the duplex status register is used
for.  To keep from confusing the user, we are removing the duplex register
from the ethtool dump of the registers.

Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: John Ronciak <john.ronciak@intel.com>
---

 e1000.c |    2 --
 1 files changed, 0 insertions(+), 2 deletions(-)

diff --git a/e1000.c b/e1000.c
index 77d799f..6de27ca 100644
--- a/e1000.c
+++ b/e1000.c
@@ -282,7 +282,6 @@ e1000_dump_regs(struct ethtool_drvinfo *
 	reg = regs_buff[0];
 	fprintf(stdout,
 		"0x00000: CTRL (Device control register)  0x%08X\n"
-		"      Duplex:                            %s\n"
 		"      Endian mode (buffers):             %s\n"
 		"      Link reset:                        %s\n"
 		"      Set link up:                       %s\n"
@@ -291,7 +290,6 @@ e1000_dump_regs(struct ethtool_drvinfo *
 		"      Transmit flow control:             %s\n"
 		"      VLAN mode:                         %s\n",
 		reg,
-		reg & E1000_CTRL_FD     ? "full"     : "half",
 		reg & E1000_CTRL_BEM    ? "big"      : "little",
 		reg & E1000_CTRL_LRST   ? "reset"    : "normal",
 		reg & E1000_CTRL_SLU    ? "1"        : "0",
