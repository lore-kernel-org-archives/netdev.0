From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: [PATCH net-next 2/2] net: netcp: select davinci_mdio driver by
 default
Date: Fri, 27 Feb 2015 15:56:09 -0500
Message-ID: <54F0D9E9.1020705@ti.com>
References: <1424813251-31610-1-git-send-email-m-karicheri2@ti.com> <1424813251-31610-2-git-send-email-m-karicheri2@ti.com> <20150227162921.GX11056@atomide.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <mugunthanvnm@ti.com>,
	<prabhakar.csengg@gmail.com>, <varkabhadram@gmail.com>,
	<netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<grygorii.strashko@ti.com>, <lokeshvutla@ti.com>,
	<mpa@pengutronix.de>, <w-kwok2@ti.com>
To: Tony Lindgren <tony@atomide.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150227162921.GX11056@atomide.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 02/27/2015 11:29 AM, Tony Lindgren wrote:
> * Murali Karicheri<m-karicheri2@ti.com>  [150224 13:31]:
>> Keystone netcp driver re-uses davinci mdio driver. So enable it
>> by default for keystone netcp driver.
>>
>> Signed-off-by: Murali Karicheri<m-karicheri2@ti.com>
>> ---
>>   drivers/net/ethernet/ti/Kconfig |    1 +
>>   1 file changed, 1 insertion(+)
>>
>> diff --git a/drivers/net/ethernet/ti/Kconfig b/drivers/net/ethernet/ti/Kconfig
>> index 3bc992c..945a221 100644
>> --- a/drivers/net/ethernet/ti/Kconfig
>> +++ b/drivers/net/ethernet/ti/Kconfig
>> @@ -88,6 +88,7 @@ config TI_CPTS
>>   config TI_KEYSTONE_NETCP
>>   	tristate "TI Keystone NETCP Core Support"
>>   	select TI_CPSW_ALE
>> +	select TI_DAVINCI_MDIO
>>   	depends on OF
>>   	depends on KEYSTONE_NAVIGATOR_DMA&&  KEYSTONE_NAVIGATOR_QMSS
>>   	---help---
>
> These options should be silent Kconfig options if we're selecting
> them. Or else you should use depends on instead.
>
Just followed the existing implementation as it made sense.

config TI_DAVINCI_EMAC
	tristate "TI DaVinci EMAC Support"
	depends on ARM && ( ARCH_DAVINCI || ARCH_OMAP3 )
	select TI_DAVINCI_MDIO
	select TI_DAVINCI_CPDMA
	select PHYLIB
	---help---
	  This driver supports TI's DaVinci Ethernet .

	  To compile this driver as a module, choose M here: the module
	  will be called davinci_emac_driver.  This is recommended.

config TI_CPSW
	tristate "TI CPSW Switch Support"
	depends on ARCH_DAVINCI || ARCH_OMAP2PLUS
	select TI_DAVINCI_CPDMA
	select TI_DAVINCI_MDIO
	select TI_CPSW_PHY_SEL
	select TI_CPSW_ALE
	select MFD_SYSCON
	select REGMAP
	---help---
	  This driver supports TI's CPSW Ethernet Switch.

	  To compile this driver as a module, choose M here: the module
	  will be called cpsw.

Why it has to be silent options? NetCP driver would require DAVINCI_MDIO 
driver to function. So "select" make sense to me instead of "depend". 
How do you think depend can be used here?

Murali

> In general using select for driver modules will eventually lead into
> randconfig build failures as things change.
>
> Regards,
>
> Tony


-- 
Murali Karicheri
Linux Kernel, Texas Instruments
