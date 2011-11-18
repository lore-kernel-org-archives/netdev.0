From: "Aries Lee" <arieslee@jmicron.com>
Subject: RE: [PATCH 1/1]  PHY configuration for compatible issue
Date: Fri, 18 Nov 2011 15:13:37 +0800
Message-ID: <201111180713.pAI7Df9w013423@jmr105.jmicron.com>
References: <20111117070537.M4900@cooldavid.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "'AriesLee'" <AriesLeeILan@gmail.com>
To: "'Guo-Fu Tseng'" <cooldavid@cooldavid.org>,
	<netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from spamfilter.jmicron.com ([220.130.51.235]:6669 "EHLO
	jmsspam.jmicron.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751022Ab1KRHOA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Nov 2011 02:14:00 -0500
In-Reply-To: <20111117070537.M4900@cooldavid.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Guo-Fu and All

	Because jme_phy_on() and jme_phy_off() just turn on/off the PHY, the
value of extern register is still the power on default value, not the most
robust value which we collect in the LAB.
It still need to config those registers to the proper value when the chip
lost the power and power on again.

B.R
Aries
-----Original Message-----
From: Guo-Fu Tseng [mailto:cooldavid@cooldavid.org] 
Sent: Thursday, November 17, 2011 3:15 PM
To: AriesLee; netdev@vger.kernel.org
Cc: AriesLee
Subject: Re: [PATCH 1/1] PHY configuration for compatible issue

On Thu, 17 Nov 2011 22:05:42 +0800, AriesLee wrote
> From: Aries Lee <AriesLee@jmicron.com>
> 
> To perform PHY calibration and set a different EA value by chip ID,
> Whenever the NIC chip power on, ie booting or resuming, we need to
> force HW to calibrate PHY parameter again, and also set a proper EA
> value which gathered from experiment.
> 
> That process resolve the compatible issues(NIC is unable to link
> up in some special case) in giga speed.
Thank you Aries.

Here is some suggestions after a quick review:

It would be better if you implement the read/write function
for extended-phy-register, instead of using JM_PHY_SPEC_ADDR_REG
and JM_PHY_SPEC_DATA_REG directly all the time.

There are jme_phy_on() and jme_phy_off() function in place.
Should you simply using it?
