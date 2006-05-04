From: Pavel Roskin <proski@gnu.org>
Subject: dBm cutoff at -1dBm is too low
Date: Thu, 04 May 2006 12:37:45 -0400
Message-ID: <1146760665.5294.65.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:40351 "EHLO
	fencepost.gnu.org") by vger.kernel.org with ESMTP id S1030196AbWEDQhy
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 May 2006 12:37:54 -0400
Received: from proski by fencepost.gnu.org with local (Exim 4.34)
	id 1Fbgps-0007XO-AD
	for netdev@vger.kernel.org; Thu, 04 May 2006 12:37:52 -0400
To: Jean Tourrilhes <jt@hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Jean!

I'm converting Orinoco to the dBm reporting, and it turns out that the
best signal iwconfig will report is -1dBm (0.8mW).  This would happen if
qual->level has its highest value of 255.  Please see this code from
wireless_tools.29.pre10:

len = snprintf(buffer, buflen, "Signal level%c%d dBm  ",
               qual->updated & IW_QUAL_LEVEL_UPDATED ? '=' : ':',
               qual->level - 0x100);

With most cards transmitting at 100mW and some going as high as 500mW,
it's not unreasonable to expect that the received signal may exceed 1mW
for closely located receivers with good antennas.  I have seen HostAP
reporting as much as 3mW through the proc filesystem!

Wouldn't it be better to put the cutoff at a higher value?  The simplest
approach would be to treat qual->level and qual->noise as signed char,
which would put the cutoff and 127dBm.  500 gigawatts should be enough
for everyone :-)

-- 
Regards,
Pavel Roskin

