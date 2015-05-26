From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH] net: phy: dp83867: Add TI dp83867 phy
Date: Tue, 26 May 2015 13:50:54 -0500
Message-ID: <5564C08E.2090400@ti.com>
References: <1432645679-4759-1-git-send-email-dmurphy@ti.com> <5564B5A2.4080508@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:37043 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbbEZSuy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 May 2015 14:50:54 -0400
In-Reply-To: <5564B5A2.4080508@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian

Thanks for the review!

On 05/26/2015 01:04 PM, Florian Fainelli wrote:
> On 26/05/15 06:07, Dan Murphy wrote:
>> Add support for the TI dp83867 Gigabit ethernet phy
>> device.
>>
>> The DP83867 is a robust, low power, fully featured
>> Physical Layer transceiver with integrated PMD
>> sublayers to support 10BASE-T, 100BASE-TX and
>> 1000BASE-T Ethernet protocols.
>>
>> Signed-off-by: Dan Murphy <dmurphy@ti.com>
>> ---
> [snip]
>
>> +
>> +int rx_tx_delay = (DP83867_RGMIIDCTL_2_75_NS << DP83867_RGMII_RX_CLK_DELAY_SHIFT) | DP83867_RGMIIDCTL_2_25_NS;
>> +module_param(rx_tx_delay, int, 0664);
> This is not going to work, rx and tx delays are inherent properties of
> PCB/board designs, you want to be able to get that value from your
> platform configuration, Device Tree would certainly be preferred here.
> Asking an user to figure this out through module parameters is going to
> be both error prone, and limiting yourself to no more than one instance.

Yeah I agree.  I also have platform data for legacy products that I could put in the
DT as well.

> [snip]
>
>> +
>> +static int dp83867_phy_reset(struct phy_device *phydev)
>> +{
>> +	int err;
>> +
>> +	err = phy_write(phydev, DP83867_CTRL, DP83867_SW_RESET);
>> +	if (err < 0)
>> +		return err;
>> +
>> +	err = dp83867_config_init(phydev);
>> +	return err;
> you could do a tail-call return directly?

Yep.  Will change that

>
> [snip]
>
>> +
>> +static int __init dp83867_init(void)
>> +{
>> +	return phy_driver_register(&dp83867_driver);
>> +}
>> +
>> +static void __exit dp83867_exit(void)
>> +{
>> +	phy_driver_unregister(&dp83867_driver);
>> +}
>> +
>> +module_init(dp83867_init);
>> +module_exit(dp83867_exit);
> You could use module_phy_driver to eliminate some boilerplate here.

Nice I will do that.

Dan

-- 
------------------
Dan Murphy
