From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Thu, 24 Apr 2014 21:00:49 +0800
Message-ID: <53590B01.8070105@linaro.org>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <201404221630.07865.arnd@arndb.de> <53568398.2030800@linaro.org> <201404241428.10248.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-arm-kernel@lists.infradead.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, xuwei5@hisilicon.com,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:61413 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753253AbaDXNA6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Apr 2014 09:00:58 -0400
Received: by mail-pa0-f50.google.com with SMTP id rd3so1885427pab.23
        for <netdev@vger.kernel.org>; Thu, 24 Apr 2014 06:00:58 -0700 (PDT)
In-Reply-To: <201404241428.10248.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/24/2014 08:28 PM, Arnd Bergmann wrote:
> On Tuesday 22 April 2014, zhangfei wrote:
>> On 04/22/2014 10:30 PM, Arnd Bergmann wrote:
>>> On Tuesday 22 April 2014, zhangfei wrote:
>>>> On 04/22/2014 04:22 PM, Arnd Bergmann wrote:
>
>>> But it means that the hip04_mdio driver potentially won't work if connected
>>> to something other than a Marvell PHY.
>>>
>>> I noticed that the marvell_of_reg_init() does this at init time:
>>>
>>> saved_page = phy_read(phydev, MII_MARVELL_PHY_PAGE);
>>> ... /* perform init */
>>> if (page_changed)
>>>        phy_write(phydev, MII_MARVELL_PHY_PAGE, saved_page);
>>>
>>> Is this a bug? Maybe it should always set page 0 when leaving
>>> this function.
>>>
>> It is correct behavior return to the original page.
>>
>> First get_phy_id, then match driver according to the id, then operation
>> in the specific driver have the chance to run, including
>> marvell_of_reg_init etc.
>>
>> Just unlucky the default value of PHY_PAGE after power on is not 0.
>
> Ok, so it's actually not possible to detect this case prior to having
> to work around it.
>
> How about adding a DT property as a flag to tell the driver whether
> to set the page to zero or not? That would let the driver work
> with different types of PHY implementations, or skip the code if
> there is firmware that can already set it up to page zero.
>

Currently we suspect it maybe caused by bootloader (uefi) has accessed 
page register and forgot to recover, still in double confirm.
Even it not caused by uefi, we can set to page 0 in uefi, and let mdio 
driver common to other phy.
So we may remove the bus->reset, and let uefi do the preparation.

Thanks
