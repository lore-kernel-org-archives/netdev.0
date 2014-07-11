From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Question about settings array in phy.c
Date: Fri, 11 Jul 2014 10:50:59 -0500
Message-ID: <53C007E3.4010009@amd.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>
To: netdev <netdev@vger.kernel.org>,
	Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2lp0205.outbound.protection.outlook.com ([207.46.163.205]:35398
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753510AbaGKPvW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Jul 2014 11:51:22 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In drivers/net/phy/phy.c there is an array of struct phy_setting named
settings that is used when auto negotiation is disabled to sanitize
the phy settings.  This array uses only *baseT* features for validating
the various speed/duplex combinations.  This may result in not finding
the correct array entry in regards to speed and duplex if the *baseT*
feature is not supported.

For example, a 10GbE phy that supports KR mode would end up not matching
an entry and defaulting to the last entry of the array (SPEED_10 and
DUPLEX_HALF) which is not what is desired.

Is it appropriate to be able to extend this array?  Either by adding
additional array entries or extending the "setting" to include other
features?  Or is there a specific reason that only the *baseT* values
are used?

Examples of changing the array:

   Add a new entry
	{
		.speed = SPEED_10000,
		.duplex = DUPLEX_FULL,
		.setting = SUPPORTED_10000baseKR_Full,
	},

   or extend current entry
	{
		.speed = SPEED_10000,
		.duplex = DUPLEX_FULL,
		.setting = SUPPORTED_10000baseT_Full |
			   SUPPORTED_10000baseKR_Full,
	},

Thanks,
Tom
