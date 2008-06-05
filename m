From: Felix Fietkau <nbd@openwrt.org>
Subject: Re: RFC: Custom PHY device detection functions
Date: Thu, 05 Jun 2008 22:19:46 +0200
Message-ID: <48484A62.8010208@openwrt.org>
References: <4847013B.4090408@openwrt.org> <Pine.LNX.4.64.0806051152050.3242@t2.domain.actdsltmp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Trent Piepho <tpiepho@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nbd.name ([88.198.39.176]:33959 "EHLO ds10.mine.nu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751954AbYFEUTx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Jun 2008 16:19:53 -0400
In-Reply-To: <Pine.LNX.4.64.0806051152050.3242@t2.domain.actdsltmp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Trent Piepho wrote:
> On Wed, 4 Jun 2008, Felix Fietkau wrote:
>> I'm working on Linux on small consumer grade wireless routers. Many of these 
>> have switches that connect directly to the Ethernet controller through 
>> MII/MDIO. These typically support 6-8 ports, one of which connects to the 
>> CPU. I am working on supporting some of these with PHY drivers, which I will 
>> submit for review when they're ready.
>> Most of these devices can be detected with the regular PHY ID and mask, but 
>> unfortunately there are some that lay out their registers a bit differently 
>> and thus need custom detection.
>> I worked around this with the following patch, that allows drivers to do 
>> their own detection, but I'm not sure if this is suitable for inclusion in 
>> the PHY layer or if there is a different way to solve this.
>> Any ideas?
> 
> If the phy uses non-standard registers, isn't it too late after the phy
> layer has already read the phy_id?
Reading phy_id does not cause any problems, it just doesn't give us 
anything base detection on.

> If not, could you use the existing probe function?  Set phy_id_mask to 0 and
> have the probe function return ENODEV if it's the wrong device.  I think the
> driver layer will go through all matching drivers, calling each one's probe
> function, until one of them claims the device.
Thanks, I'll try that.

- Felix
