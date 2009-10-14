From: "Eilon Greenstein" <eilong@broadcom.com>
Subject: [net-next 0/8] bnx2x: Device Control Channel bug fixes
Date: Wed, 14 Oct 2009 17:07:05 +0200
Message-ID: <1255532825.25030.35.camel@lb-tlvb-eilong>
Reply-To: eilong@broadcom.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:3224 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756676AbZJNPHz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 14 Oct 2009 11:07:55 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

This bnx2x patch series is fixing some bugs that relates to the Device
Control Channel (DCC) code. There are actually 3 different failures:

1. When the fairness initial value was set to zero, the device could not
be enabled. This is caused since zero indicated that the mechanism is
disabled, and the code (both FW and driver) was not ready to allow
enabling it at run time. This patch requires replacing the FW - to allow
easier review, it is split to 3 patches:
        P1: adding the new FW
        P2: the actually patch
        P3: removing the old FW
        
2. Races when loading/unloading the driver when DCC link enable/disable
commands are received. There were 3 different races:
        P4: The state of the driver which indicates if it is loaded or
        not was also used to signal if its link is enabled/disabled by
        DCC
        P5: The FW commands to acknowledge the DCC command and
        loading/unloading the driver run over each other
        P6: Setting/clearing the MAC address and the FW filtering rules
        
3.	P7: Reporting the maximal BW as the link speed

Patch number 8 is the version update.

The patches were made based on net-next. Since those are bug fixes,
please let me know if I should send them based on net-2.6 as well.

Thanks,
Eilon



