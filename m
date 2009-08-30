From: Marcel Holtmann <marcel@holtmann.org>
Subject: [PATCH 10/47] Bluetooth: Add documentation for Marvell Bluetooth driver
Date: Sun, 30 Aug 2009 01:50:24 -0700
Message-ID: <196be0cd018068d545e1d764094c7b07aaf0bcfe.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
 <fd0b3ff707dc1f7837079044bd4eca7ed505f70d.1251621661.git.marcel@holtmann.org>
 <981b1414d78a7a42cab48b97d4de54a62d61db88.1251621661.git.marcel@holtmann.org>
 <290ba200815fdecb4d40dc942499c4ea6d0c4624.1251621661.git.marcel@holtmann.org>
 <364f63519d94442ed373ac7da79033c8282df46a.1251621661.git.marcel@holtmann.org>
 <9eba32b86d17ef87131fa0bce43c614904ab5781.1251621661.git.marcel@holtmann.org>
 <edad63886993d18ab800c49f6587a93432ef8b35.1251621661.git.marcel@holtmann.org>
 <132ff4e5fa8dfb71a7d99902f88043113947e972.1251621661.git.marcel@holtmann.org>
 <789221ecc870117b77e354d488d5d29f15410de8.1251621661.git.marcel@holtmann.org>
 <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from senator.holtmann.net ([87.106.208.187]:53263 "EHLO
	mail.holtmann.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752862AbZH3IwB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 30 Aug 2009 04:52:01 -0400
In-Reply-To: <fb784f0508d5aa39a23e72879a8dfb517c6f6e7f.1251621661.git.marcel@holtmann.org>
In-Reply-To: <cover.1251621661.git.marcel@holtmann.org>
References: <cover.1251621661.git.marcel@holtmann.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bing Zhao <bzhao@marvell.com>

add btmrvl.txt to Documentation/

This patch incorporates a lot of comments given by
Nicolas Pitre <nico@marvell.com>. Many thanks to Nicolas Pitre.

Signed-off-by: Rahul Tank <rahult@marvell.com>
Signed-off-by: Bing Zhao <bzhao@marvell.com>
Signed-off-by: Marcel Holtmann <marcel@holtmann.org>
---
 Documentation/00-INDEX   |    2 +
 Documentation/btmrvl.txt |  119 ++++++++++++++++++++++++++++++++++++++++++++++
 2 files changed, 121 insertions(+), 0 deletions(-)
 create mode 100644 Documentation/btmrvl.txt

diff --git a/Documentation/00-INDEX b/Documentation/00-INDEX
index d05737a..06b982a 100644
--- a/Documentation/00-INDEX
+++ b/Documentation/00-INDEX
@@ -82,6 +82,8 @@ block/
 	- info on the Block I/O (BIO) layer.
 blockdev/
 	- info on block devices & drivers
+btmrvl.txt
+	- info on Marvell Bluetooth driver usage.
 cachetlb.txt
 	- describes the cache/TLB flushing interfaces Linux uses.
 cdrom/
diff --git a/Documentation/btmrvl.txt b/Documentation/btmrvl.txt
new file mode 100644
index 0000000..34916a4
--- /dev/null
+++ b/Documentation/btmrvl.txt
@@ -0,0 +1,119 @@
+=======================================================================
+		README for btmrvl driver
+=======================================================================
+
+
+All commands are used via debugfs interface.
+
+=====================
+Set/get driver configurations:
+
+Path:	/debug/btmrvl/config/
+
+gpiogap=[n]
+hscfgcmd
+	These commands are used to configure the host sleep parameters.
+	bit 8:0  -- Gap
+	bit 16:8 -- GPIO
+
+	where GPIO is the pin number of GPIO used to wake up the host.
+	It could be any valid GPIO pin# (e.g. 0-7) or 0xff (SDIO interface
+	wakeup will be used instead).
+
+	where Gap is the gap in milli seconds between wakeup signal and
+	wakeup event, or 0xff for special host sleep setting.
+
+	Usage:
+		# Use SDIO interface to wake up the host and set GAP to 0x80:
+		echo 0xff80 > /debug/btmrvl/config/gpiogap
+		echo 1 > /debug/btmrvl/config/hscfgcmd
+
+		# Use GPIO pin #3 to wake up the host and set GAP to 0xff:
+		echo 0x03ff >  /debug/btmrvl/config/gpiogap
+		echo 1 > /debug/btmrvl/config/hscfgcmd
+
+psmode=[n]
+pscmd
+	These commands are used to enable/disable auto sleep mode
+
+	where the option is:
+			1 	-- Enable auto sleep mode
+			0 	-- Disable auto sleep mode
+
+	Usage:
+		# Enable auto sleep mode
+		echo 1 > /debug/btmrvl/config/psmode
+		echo 1 > /debug/btmrvl/config/pscmd
+
+		# Disable auto sleep mode
+		echo 0 > /debug/btmrvl/config/psmode
+		echo 1 > /debug/btmrvl/config/pscmd
+
+
+hsmode=[n]
+hscmd
+	These commands are used to enable host sleep or wake up firmware
+
+	where the option is:
+			1	-- Enable host sleep
+			0	-- Wake up firmware
+
+	Usage:
+		# Enable host sleep
+		echo 1 > /debug/btmrvl/config/hsmode
+		echo 1 > /debug/btmrvl/config/hscmd
+
+		# Wake up firmware
+		echo 0 > /debug/btmrvl/config/hsmode
+		echo 1 > /debug/btmrvl/config/hscmd
+
+
+======================
+Get driver status:
+
+Path:	/debug/btmrvl/status/
+
+Usage:
+	cat /debug/btmrvl/status/<args>
+
+where the args are:
+
+curpsmode
+	This command displays current auto sleep status.
+
+psstate
+	This command display the power save state.
+
+hsstate
+	This command display the host sleep state.
+
+txdnldrdy
+	This command displays the value of Tx download ready flag.
+
+
+=====================
+
+Use hcitool to issue raw hci command, refer to hcitool manual
+
+	Usage: Hcitool cmd <ogf> <ocf> [Parameters]
+
+	Interface Control Command
+	hcitool cmd 0x3f 0x5b 0xf5 0x01 0x00    --Enable All interface
+	hcitool cmd 0x3f 0x5b 0xf5 0x01 0x01    --Enable Wlan interface
+	hcitool cmd 0x3f 0x5b 0xf5 0x01 0x02    --Enable BT interface
+	hcitool cmd 0x3f 0x5b 0xf5 0x00 0x00    --Disable All interface
+	hcitool cmd 0x3f 0x5b 0xf5 0x00 0x01    --Disable Wlan interface
+	hcitool cmd 0x3f 0x5b 0xf5 0x00 0x02    --Disable BT interface
+
+=======================================================================
+
+
+SD8688 firmware:
+
+/lib/firmware/sd8688_helper.bin
+/lib/firmware/sd8688.bin
+
+
+The images can be downloaded from:
+
+git.infradead.org/users/dwmw2/linux-firmware.git/libertas/
-- 
1.6.2.5

