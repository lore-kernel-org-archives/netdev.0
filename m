From: Dongpo Li <lidongpo@hisilicon.com>
Subject: Re: [PATCH v2 net-next 1/2] phy: add phy fixup unregister functions
Date: Fri, 16 Dec 2016 10:05:36 +0800
Message-ID: <58534BF0.7030905@hisilicon.com>
References: <9235D6609DB808459E95D78E17F2E43D4097999C@CHN-SV-EXMX02.mchp-main.com>
 <58510539.1030803@hisilicon.com>
 <9235D6609DB808459E95D78E17F2E43D40981BCB@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <andrew@lunn.ch>, <netdev@vger.kernel.org>,
        <UNGLinuxDriver@microchip.com>
To: <Woojung.Huh@microchip.com>, <davem@davemloft.net>,
        <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga01-in.huawei.com ([58.251.152.64]:40074 "EHLO
        szxga01-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1758914AbcLPCFe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 21:05:34 -0500
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40981BCB@CHN-SV-EXMX02.mchp-main.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 2016/12/14 23:34, Woojung.Huh@microchip.com wrote:
>> I just want to commit the unregister patch and found this patch. Good job!
>> But I consider this patch may miss something.
>> If one SoC has 2 MAC ports and each port uses the different network driver,
>> the 2 drivers may register fixup for the same PHY chip with different
>> "run" function because the PHY chip works in different mode.
>> In such a case, this patch doesn't consider "run" function and may cause
>> problem.
>> When removing the driver which register fixup at last, it will remove another
>> driver's fixup.
>> Should this condition be considered and fixed?
> Good point.
> Current phy fixup is independent LIST from phydev structure,
> and, fixup runs in two places of phy_device_register() and phy_init_hw().
> It's not clear that it needs two separate fixup, but it may be good idea to
> pass phy fixup when calling phy_attach() or phy_attach_direct() and
> put it under phydev structure.
> So, fixup can be called at phy_init_hw() per phy device and remove
> When phy detached.
> Welcome any comments.

I rethink this problem and find that the "fixup->bus_id" may be a flag to
distinguish different PHY device.
In such condition, the driver should call "phy_register_fixup/phy_unregister_fixup" directly
instead of "*_for_uid" interface.


    Regards,
    Dongpo

.
