From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/5] net: dsa: b53: Add support for Broadcom
 RoboSwitch
Date: Fri, 10 Jun 2016 11:49:08 -0700
Message-ID: <575B0BA4.9010708@gmail.com>
References: <1465521837-30193-1-git-send-email-f.fainelli@gmail.com>
 <1465521837-30193-2-git-send-email-f.fainelli@gmail.com>
 <20160610121149.GC2338@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, vivien.didelot@savoirfairelinux.com,
	davem@davemloft.net, jon.mason@broadcom.com,
	hemal.shah@broadcom.com, bandaru.viswanath@broadcom.com,
	michael.chan@broadcom.com, jogo@openwrt.org, cphealy@gmail.com,
	ardeleanalex@gmail.com, jiri@mellanox.com, idosch@mellanox.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f65.google.com ([209.85.220.65]:33237 "EHLO
	mail-pa0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751632AbcFJStK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 10 Jun 2016 14:49:10 -0400
Received: by mail-pa0-f65.google.com with SMTP id di3so5576563pab.0
        for <netdev@vger.kernel.org>; Fri, 10 Jun 2016 11:49:10 -0700 (PDT)
In-Reply-To: <20160610121149.GC2338@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/10/2016 05:11 AM, Andrew Lunn wrote:
>> +static void b53_switch_reset_gpio(struct b53_device *dev)
>> +{
>> +	int gpio = dev->reset_gpio;
>> +
>> +	if (gpio < 0)
>> +		return;
>> +
>> +	/* Reset sequence: RESET low(50ms)->high(20ms)
>> +	 */
>> +	gpio_set_value(gpio, 0);
>> +	mdelay(50);
>> +
>> +	gpio_set_value(gpio, 1);
>> +	mdelay(20);
>> +
>> +	dev->current_page = 0xff;
>> +}
> 
> Hi Florian
> 
> It would be better to use the gpiod API here, so the active hi/active
> low flag is respected.

OK.

> 
>> +	dev->reset_gpio = b53_switch_get_reset_gpio(dev);
>> +	if (dev->reset_gpio >= 0) {
>> +		ret = devm_gpio_request_one(dev->dev, dev->reset_gpio,
>> +					    GPIOF_OUT_INIT_HIGH, "robo_reset");
>> +		if (ret)
>> +			return ret;
>> +	}
>> +
>> +	return 0;
>> +}
> 
>> +static inline int b53_switch_get_reset_gpio(struct b53_device *dev)
>> +{
>> +	enum bcm47xx_board board = bcm47xx_board_get();
>> +
>> +	switch (board) {
>> +	case BCM47XX_BOARD_LINKSYS_WRT300NV11:
>> +	case BCM47XX_BOARD_LINKSYS_WRT310NV1:
>> +		return 8;
> 
> Rather than hard coding it, could we get it from device tree?

Difficult for now, this is for in-tree MIPS-based platforms under
arch/mips/bcm47xx, which are using SSB/platform data.
-- 
Florian
