From: Greg KH <gregkh@suse.de>
Subject: [patch 06/31] sky2: turn on clocks when doing resume
Date: Wed, 11 Apr 2007 15:51:32 -0700
Message-ID: <20070411225132.GG24814@kroah.com>
References: <20070411224329.866978349@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1161408AbXDKXEm@vger.kernel.org>
Content-Disposition: inline; filename="sky2-ec-clocks-resume.patch"
In-Reply-To: <20070411225100.GA24814@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

-stable review patch.  If anyone has any objections, please let us know.

------------------
From: Stephen Hemminger <shemminger@linux-foundation.org>

Some of these chips are disabled until clock is enabled.
This fixes:
     http://bugs.debian.org/cgi-bin/bugreport.cgi?bug=404107

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |    7 +++++++
 1 file changed, 7 insertions(+)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -2421,6 +2421,10 @@ static int sky2_reset(struct sky2_hw *hw
 		return -EOPNOTSUPP;
 	}
 
+	/* Make sure and enable all clocks */
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
+
 	hw->chip_rev = (sky2_read8(hw, B2_MAC_CFG) & CFG_CHIP_R_MSK) >> 4;
 
 	/* This rev is really old, and requires untested workarounds */
@@ -3639,6 +3643,9 @@ static int sky2_resume(struct pci_dev *p
 
 	pci_restore_state(pdev);
 	pci_enable_wake(pdev, PCI_D0, 0);
+
+	if (hw->chip_id == CHIP_ID_YUKON_EC_U)
+		sky2_pci_write32(hw, PCI_DEV_REG3, 0);
 	sky2_set_power_state(hw, PCI_D0);
 
 	err = sky2_reset(hw);

-- 
