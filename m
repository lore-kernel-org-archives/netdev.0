From: zhangfei <zhangfei.gao@linaro.org>
Subject: Re: [PATCH v8 2/3] net: hisilicon: new hip04 MDIO driver
Date: Tue, 22 Apr 2014 22:16:06 +0800
Message-ID: <535679A6.4020103@linaro.org>
References: <1397869980-21187-1-git-send-email-zhangfei.gao@linaro.org> <535561BE.9070303@cogentembedded.com> <5356063C.6070100@linaro.org> <10652983.rXrAGMo8Yn@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Mark Rutland <mark.rutland@arm.com>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	Russell King <linux@arm.linux.org.uk>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>, xuwei5@hisilicon.com,
	David Laight <David.Laight@aculab.com>,
	David Miller <davem@davemloft.net>
To: Arnd Bergmann <arnd@arndb.de>, linux-arm-kernel@lists.infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52529 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756425AbaDVOQP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 10:16:15 -0400
Received: by mail-pd0-f173.google.com with SMTP id z10so4921615pdj.18
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 07:16:14 -0700 (PDT)
In-Reply-To: <10652983.rXrAGMo8Yn@wuerfel>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 04/22/2014 04:22 PM, Arnd Bergmann wrote:

>> It's private register of the phy marvell 88e1512.
>> To make it clearer using define instead.
>> #define MII_MARVELL_PHY_PAGE    22
>>
>> The registers has been grouped into several pages, access register need
>> choose which page first.
>
> You shouldn't touch the PHY private registers in the main driver though,
> this should be purely handled by drivers/net/phy/marvell.c.
>
> I don't see support for 88e1512 there, only 88e1510 and lots of older
> ones, but I assume it isn't hard to add.
>

88e1512 driver is already supported, same as 88e1510.
#define MARVELL_PHY_ID_MASK             0xfffffff0
So it should support 88e151x.

Reset is required here for get_phy_id, otherwise only 0 can be get.
phy_device_create will not be called, and can not match any driver.

However in the experiment, it is found BMCR_RESET is not required in fact.
Only hip04_mdio_write(bus, i, MII_MARVELL_PHY_PAGE, 0) has to be set.
88e151x registers are divided into pages.
Generic MII registers is in page 0, including MII_PHYSID1 and MII_PHYSID2.
Unfortunately the default page is not 0, so get_phy_id will fail.

So bus->reset still required to set the page to 0, prepared for get_phy_id.

Thanks
