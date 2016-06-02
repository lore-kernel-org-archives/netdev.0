From: Mario Limonciello <mario_limonciello@dell.com>
Subject: [PATCH v2] r8152: Add support for setting MAC to system's Auxiliary MAC address
Date: Thu,  2 Jun 2016 11:58:06 -0500
Message-ID: <1464886687-16284-1-git-send-email-mario_limonciello@dell.com>
Cc: LKML <linux-kernel@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	Linux USB <linux-usb@vger.kernel.org>, pali.rohar@gmail.com,
	anthony.wong@canonical.com, Greg KH <gregkh@linuxfoundation.org>,
	Mario Limonciello <mario_limonciello@dell.com>
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This adjusts a lot of concerns that have been raised on LKML.

Changes from v1:
 * Lots of error checking around bad ACPI data
 * Only activate on Dell system vendor DMI string
 * Use hex2bin instead of inventing a wheel
 * Copy MAC to both dev_addr and sa_data
 * Track and set only for one NIC at a time
 * If MAC lookup failed (bad ACPI data or bad return) fall back
   to regular r8152 MAC setting routine.

This has been tested with TB15, WD15 docks and Dell P/N 96NP5 dongle.
It's also been tested with two devices that use r8152 simultaneously.

Remaining discussion points:
 * Greg KH had asked this to only on machines that are known to have
   \\_SB.AMAC
 - I would rather avoid doing this because the list will just grow every
   year.  I've added lots of error checking and restricted this to Dell.
 * There was also a request to move this to an x86
   arch_get_platform_mac_address() implementation.  
 - I haven't yet done this.  If this is the right approach.
   I would like to know the proper place in arch/x86 to put this code.
   My initial thought was a new file in arch/x86/platform/intel

Mario Limonciello (1):
  r8152: Add support for setting MAC to system's Auxiliary MAC address

 drivers/net/usb/r8152.c | 53 +++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 53 insertions(+)

-- 
2.7.4
