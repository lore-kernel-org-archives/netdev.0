From: Mason <slash.tmp@free.fr>
Subject: Re: [PATCH 1/2] net: phy: at803x: Fix RGMII RX and TX clock delays
 setup
Date: Wed, 19 Jul 2017 23:29:01 +0200
Message-ID: <03f68f8b-edd6-f976-39d0-a580ccb888d5@free.fr>
References: <b332dc3e-4478-e34b-2b3f-226aad8a11d4@sigmadesigns.com>
 <33ed5f4f-9939-dc00-b973-db39c16f2393@sigmadesigns.com>
 <5ea9905f-e74a-4a43-dc5b-883ec9daf030@ti.com>
 <abbcd40c-5ecd-2197-73d0-2046cf1e7b5c@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Linux ARM <linux-arm-kernel@lists.infradead.org>,
        "David S. Miller" <davem@davemloft.net>,
        Thibaud Cornic <thibaud_cornic@sigmadesigns.com>
To: Florian Fainelli <f.fainelli@gmail.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>,
        Marc Gonzalez <marc_gonzalez@sigmadesigns.com>,
        Andrew Lunn <andrew@lunn.ch>, Mans Rullgard <mans@mansr.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Fabio Estevam <fabio.estevam@nxp.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Timur Tabi <timur@codeaurora.org>,
        Daniel Mack <zonque@gmail.com>, Sekhar Nori <nsekhar@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2-g21.free.fr ([212.27.42.2]:58806 "EHLO smtp2-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753888AbdGSV3l (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 19 Jul 2017 17:29:41 -0400
In-Reply-To: <abbcd40c-5ecd-2197-73d0-2046cf1e7b5c@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19/07/2017 21:30, Florian Fainelli wrote:
> On 07/19/2017 12:24 PM, Grygorii Strashko wrote:
>> Hi
>>
>> On 07/19/2017 10:31 AM, Marc Gonzalez wrote:
>>> The current code supports enabling RGMII RX and TX clock delays.
>>> The unstated assumption is that these settings are disabled by
>>> default at reset, which is not the case.
>>>
>>> RX clock delay is enabled at reset. And TX clock delay "survives"
>>> across SW resets. Thus, if the bootloader enables TX clock delay,
>>> it will remain enabled at reset in Linux.
>>>
>>> Provide disable functions to configure the RGMII clock delays
>>> exactly as specified in the fwspec.
>>>
>>> Signed-off-by: Marc Gonzalez <marc_gonzalez@sigmadesigns.com>
>>> ---
>>>   drivers/net/phy/at803x.c | 32 ++++++++++++++++++++++++--------
>>>   1 file changed, 24 insertions(+), 8 deletions(-)
>> This patch breaks am335x-evm networking.
>>
>> To restore it I've had to apply below diff:
>> diff --git a/arch/arm/boot/dts/am335x-evm.dts b/arch/arm/boot/dts/am335x-evm.dts
>> index 200d6ab..9578bdf 100644
>> --- a/arch/arm/boot/dts/am335x-evm.dts
>> +++ b/arch/arm/boot/dts/am335x-evm.dts
>> @@ -724,12 +724,12 @@
>>  
>>  &cpsw_emac0 {
>>         phy_id = <&davinci_mdio>, <0>;
>> -       phy-mode = "rgmii-txid";
>> +       phy-mode = "rgmii-id";
>>  };
>>  
>>  &cpsw_emac1 {
>>         phy_id = <&davinci_mdio>, <1>;
>> -       phy-mode = "rgmii-txid";
>> +       phy-mode = "rgmii-id";
>>  };
>>  
>>  &tscadc {
>>
>> Sry, can't comment here to much - not E-PHY expert.
> 
> It's useful feedback, since we had poorly defined "phy-mode" semantics
> for too long, this is totally expected, Marc this is exactly why Mans is
> suggesting additional MAC-specific properties to define delays.

In the current situation, it is impossible to configure
the at803x to disable RX clock delay or TX clock delay
(in case the boot loader enabled it).

Are you saying that, because no one has had a problem
so far, it is not possible to fix it now, as it would
break boards like am335x-evm.dts which didn't request
RX clock delay, but got one anyway?

Does that mean we cannot support boards using AR8035
that need the RX and TX clock delays disabled?

I'm not sure how the MAC-specific properties can save
the day?

Regards.
