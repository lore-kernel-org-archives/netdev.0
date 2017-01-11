From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next 1/2] phy: marvell: Add support for temperature
 sensor
Date: Wed, 11 Jan 2017 19:29:20 +0300
Message-ID: <7827301e-71bb-ad93-d6fa-350dcb5afd29@cogentembedded.com>
References: <1484096604-25033-1-git-send-email-andrew@lunn.ch>
 <1484096604-25033-2-git-send-email-andrew@lunn.ch>
 <20170111150931.GV22820@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
        Florian Fainelli <f.fainelli@gmail.com>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:34097 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1030670AbdAKQ3Y (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 11 Jan 2017 11:29:24 -0500
Received: by mail-lf0-f43.google.com with SMTP id v186so86115046lfa.1
        for <netdev@vger.kernel.org>; Wed, 11 Jan 2017 08:29:23 -0800 (PST)
In-Reply-To: <20170111150931.GV22820@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello!

On 01/11/2017 06:09 PM, Andrew Lunn wrote:

>> +static int marvell_hwmon_probe(struct phy_device *phydev,
>> +			       const struct hwmon_chip_info *chip)
>> +{
>> +	struct marvell_priv *priv = phydev->priv;
>> +	struct device *dev = &phydev->mdio.dev;
>> +	int err;
>> +
>> +	err = marvell_hwmon_name(phydev);
>> +	if (err)
>> +		return err;
>> +
>> +	priv->hwmon_dev = devm_hwmon_device_register_with_info(
>> +		dev, priv->hwmon_name, phydev, chip, NULL);
>> +
>> +	if (IS_ERR(priv->hwmon_dev))
>> +		return PTR_ERR(priv->hwmon_dev);
>> +
>> +	return 0;
>> +}
>
> 0-day has pointed out this can be simplified to just
>
>         return PTR_ERR(priv->hwmon_dev);

    PTR_ERR_OR_ZERO() maybe?

[...]

MBR, Sergei
