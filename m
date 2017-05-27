From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next 1/3] net: phy: Create sysfs reciprocal links for
 attached_dev/phydev
Date: Fri, 26 May 2017 17:02:03 -0700
Message-ID: <44f24fbd-5093-faa2-02cd-f8d4d835b59d@gmail.com>
References: <20170524193354.10739-1-f.fainelli@gmail.com>
 <20170524193354.10739-2-f.fainelli@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DAA2@CHN-SV-EXMX02.mchp-main.com>
 <d2d97683-3fcc-6603-09e1-13818464de18@gmail.com>
 <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: davem@davemloft.net, andrew@lunn.ch
To: Woojung.Huh@microchip.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:35935 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948871AbdE0ACH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 May 2017 20:02:07 -0400
Received: by mail-qk0-f194.google.com with SMTP id y128so2983339qka.3
        for <netdev@vger.kernel.org>; Fri, 26 May 2017 17:02:06 -0700 (PDT)
In-Reply-To: <9235D6609DB808459E95D78E17F2E43D40A9DACE@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/26/2017 04:52 PM, Woojung.Huh@microchip.com wrote:
> Hi Florian,
> 
>>> I knew that it is applied to net-next.
>>> However, sysfs_create_link() fails when fixed phy
>> (drivers/net/phy/fixed_phy.c)
>>> Do you have a chance to test with it?
>>
>> I did, my main test system (BCM7445 w/ bcm_sf2) has one normal PHY
>> driver and 3 fixed PHYs (including one for the CPU port/master netdev),
>> see below.
>>
>> What kind of error do you get here?
> sysfs_create_link() returns -2 (-ENOENT).
> 
>>
>> # ls -l /sys/class/net/gphy/phydev
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:00
>> /sys/class/net/gphy/phydev ->
>> ../../../f0b403c0.mdio/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05
>> # ls -l /sys/class/net/*/phydev
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:01
>> /sys/class/net/eth0/phydev -> ../../../../Fixed MDIO
>> bus.0/mdio_bus/fixed-0/fixed-0:00
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:00
>> /sys/class/net/gphy/phydev ->
>> ../../../f0b403c0.mdio/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:01
>> /sys/class/net/moca/phydev -> ../../../../../Fixed MDIO
>> bus.0/mdio_bus/fixed-0/fixed-0:02
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:01
>> /sys/class/net/rgmii_1/phydev -> ../../../mdio_bus/sf2-1/sf2-1:00
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:01
>> /sys/class/net/rgmii_2/phydev -> ../../../../../Fixed MDIO
>> bus.0/mdio_bus/fixed-0/fixed-0:01
>>
>> # ls -l /sys/class/mdio_bus/fixed-0/*/attached_dev
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:01
>> /sys/class/mdio_bus/fixed-0/fixed-0:00/attached_dev ->
>> ../../../../rdb/f04a0000.ethernet/net/eth0
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:02
>> /sys/class/mdio_bus/fixed-0/fixed-0:01/attached_dev ->
>> ../../../../rdb/rdb:switch_top@f0b00000/f0b00000.ethernet_switch/net/rgm
>> ii_2
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:02
>> /sys/class/mdio_bus/fixed-0/fixed-0:02/attached_dev ->
>> ../../../../rdb/rdb:switch_top@f0b00000/f0b00000.ethernet_switch/net/moc
>> a
>>
>> # ls -l /sys/class/mdio_bus/f0b403c0.mdio/f0b403c0.mdio\:05/attached_dev
>> lrwxrwxrwx    1 root     root             0 Jan  1 00:02
>> /sys/class/mdio_bus/f0b403c0.mdio/f0b403c0.mdio:05/attached_dev ->
>> ../../../../f0b00000.ethernet_switch/net/gphy
> 
> /sys/class/mdio_bus/devices/fixed-0:00/* exists.
> But not /sys/class/net/eth0.. because Ethernet driver initialization failed.

OK, I am confused now. You are describing what is going on with your
platform right? Can you describe a bit further here what is happening
and with which type of interface? Is this with the CPU interface or
something?
-- 
Florian
