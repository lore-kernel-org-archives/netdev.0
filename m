From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links for
 attached_dev/phydev
Date: Fri, 26 May 2017 16:44:18 -0700
Message-ID: <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:36713 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948852AbdEZXoZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 19:44:25 -0400
Received: by mail-pg0-f66.google.com with SMTP id h64so41655pge.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 16:44:25 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Woojung,

On 05/26/2017 04:34 PM, Woojung.Huh@microchip.com wrote:
>> @@ -960,6 +960,15 @@ int phy_attach_direct(struct net_device *dev, struct
>> phy_device *phydev,
>>
>>  	phydev->attached_dev = dev;
>>  	dev->phydev = phydev;
>> +	err = sysfs_create_link(&phydev->mdio.dev.kobj, &dev->dev.kobj,
>> +				"attached_dev");
>> +	if (err)
>> +		goto error;
>> +
>> +	err = sysfs_create_link(&dev->dev.kobj, &phydev->mdio.dev.kobj,
>> +				"phydev");
>> +	if (err)
>> +		goto error;
>>
> Florian,
> 
> I knew that it is applied to net-next.
> However, sysfs_create_link() fails when fixed phy (drivers/net/phy/fixed_phy.c)
> Do you have a chance to test with it?

I did, my main test system (BCM7445 w/ bcm_sf2) has one normal PHY
driver and 3 fixed PHYs (including one for the CPU port/master netdev),
see below.

What kind of error do you get here?

# ls -l /sys/class/net/gphy/phydev
lrwxrwxrwx    1 root     root             0 Jan  1 00:00
/sys/class/net/gphy/phydev ->
../../../f0b403c0.mdio/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05
# ls -l /sys/class/net/*/phydev
lrwxrwxrwx    1 root     root             0 Jan  1 00:01
/sys/class/net/eth0/phydev -> ../../../../Fixed MDIO
bus.0/mdio_bus/fixed-0/fixed-0:00
lrwxrwxrwx    1 root     root             0 Jan  1 00:00
/sys/class/net/gphy/phydev ->
../../../f0b403c0.mdio/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05
lrwxrwxrwx    1 root     root             0 Jan  1 00:01
/sys/class/net/moca/phydev -> ../../../../../Fixed MDIO
bus.0/mdio_bus/fixed-0/fixed-0:02
lrwxrwxrwx    1 root     root             0 Jan  1 00:01
/sys/class/net/rgmii_1/phydev -> ../../../mdio_bus/sf2-1/sf2-1:00
lrwxrwxrwx    1 root     root             0 Jan  1 00:01
/sys/class/net/rgmii_2/phydev -> ../../../../../Fixed MDIO
bus.0/mdio_bus/fixed-0/fixed-0:01

# ls -l /sys/class/mdio_bus/fixed-0/*/attached_dev
lrwxrwxrwx    1 root     root             0 Jan  1 00:01
/sys/class/mdio_bus/fixed-0/fixed-0:00/attached_dev ->
../../../../rdb/f04a0000.ethernet/net/eth0
lrwxrwxrwx    1 root     root             0 Jan  1 00:02
/sys/class/mdio_bus/fixed-0/fixed-0:01/attached_dev ->
../../../../rdb/rdb:switch_top@f0b00000/f0b00000.ethernet_switch/net/rgmii_2
lrwxrwxrwx    1 root     root             0 Jan  1 00:02
/sys/class/mdio_bus/fixed-0/fixed-0:02/attached_dev ->
../../../../rdb/rdb:switch_top@f0b00000/f0b00000.ethernet_switch/net/moca

# ls -l /sys/class/mdio_bus/f0b403c0.mdio/f0b403c0.mdio\:05/attached_dev
lrwxrwxrwx    1 root     root             0 Jan  1 00:02
/sys/class/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05/attached_dev ->
../../../../f0b00000.ethernet_switch/net/gphy

> 
> - Woojung
> 


-- 
Florian
