From: Philippe De Muyter <phdm@macqel.be>
Subject: [PATCH] atm : fix
	/sys/devices/virtual/atm/X/carrier(ATM_PHY_SIG_UNKNOWN)
Date: Sat, 13 Feb 2010 22:56:33 +0100
Message-ID: <20100213215633.GA4345@frolo.macqel>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: chas@cmf.nrl.navy.mil, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailrelay007.isp.belgacom.be ([195.238.6.173]:44437 "EHLO
	mailrelay007.isp.belgacom.be" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750989Ab0BMV4j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Feb 2010 16:56:39 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When trying to design udev rules to automate usage of cxacru usb atm (adsl)
modem, I have discovered that /sys/devices/virtual/atm/cxacru0/carrier had the
value '1' while actually carrier was not yet established and real carrier
state was not yet known to linux.  I propose to fix that by using '?' as the
/sys/devices/virtual/atm/cxacru0/carrier value when carrier state is not yet
known to linux.  Any other value except '1' would also be OK for me.

--
Currently, just after the interface creation,
/sys/devices/virtual/atm/cxacru0/carrier gives wrong info (carrier = 1),
while actually carrier is unknown.  Fix that.

Signed-off-by: Philippe De Muyter <phdm@macqel.be>

--- a/net/atm/atm_sysfs.c	2010-02-13 22:54:04.598847195 +0100
+++ b/net/atm/atm_sysfs.c	2010-02-13 19:13:45.395308531 +0100
@@ -63,9 +63,9 @@ static ssize_t show_carrier(struct devic
 	char *pos = buf;
 	struct atm_dev *adev = to_atm_dev(cdev);
 
-	pos += sprintf(pos, "%d\n",
-		       adev->signal ==
-		       adev->signal == ATM_PHY_SIG_LOST ? 0 : 1);
+	pos += sprintf(pos, "%c\n",
+		       adev->signal == ATM_PHY_SIG_FOUND ? '1' :
+		       adev->signal == ATM_PHY_SIG_LOST ? '0' : '?');
 
 	return pos - buf;
 }
