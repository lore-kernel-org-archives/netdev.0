From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 11:45:06 -0700
Message-ID: <37d18882-2b21-c57e-7ac1-453ff6aa5257@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
 <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
 <20170908141225.GE25219@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Tristram.Ha@microchip.com, andrew@lunn.ch, muvarov@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/08/2017 11:40 AM, Tristram.Ha@microchip.com wrote:
>> -----Original Message-----
>> From: Andrew Lunn [mailto:andrew@lunn.ch]
>> Sent: Friday, September 08, 2017 7:12 AM
>> To: Maxim Uvarov
>> Cc: Tristram Ha - C24268; Pavel Machek; Nathan Conrad; Vivien Didelot; Florian
>> Fainelli; netdev; linux-kernel@vger.kernel.org; Woojung Huh - C21699
>> Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
>> drivers can be added
>>
>> On Fri, Sep 08, 2017 at 04:32:35PM +0300, Maxim Uvarov wrote:
>>> 2017-09-08 0:54 GMT+03:00 Andrew Lunn <andrew@lunn.ch>:
>>>>> -- compatible: For external switch chips, compatible string must be exactly
>> one
>>>>> -  of: "microchip,ksz9477"
>>>>> +- compatible: Should be "microchip,ksz9477" for KSZ9477 chip,
>>>>> +           "microchip,ksz8795" for KSZ8795 chip,
>>>>> +           "microchip,ksz8794" for KSZ8794 chip,
>>>>> +           "microchip,ksz8765" for KSZ8765 chip,
>>>>> +           "microchip,ksz8895" for KSZ8895 chip,
>>>>> +           "microchip,ksz8864" for KSZ8864 chip,
>>>>> +           "microchip,ksz8873" for KSZ8873 chip,
>>>>> +           "microchip,ksz8863" for KSZ8863 chip,
>>>>> +           "microchip,ksz8463" for KSZ8463 chip
>>>>
>>>
>>> all that chips have the same spi access to get chip id on probe(). I
>>> prefer common microship,ksz-spi rather than somebody will always
>>> maintain that list.
>>
>> The Marvell DSA driver is similar. The compatibility string tells you
>> enough to go find the switch ID in the switch itself.
>>
>> I suppose this comes down to, is there going to be one SPI driver for
>> all the devices, or lots of drivers? In general, DSA has one driver
>> for lots of devices. The mv88e6xxx supports around 25 devices. The b53
>> has around 17, etc.
>>
>> So i would suggest one driver supporting all the different devices.
>>
> 
> There will be 5 drivers to support these devices:
> 
> ksz9477.c - KSZ9893/KSZ9897/KSZ9567/KSZ9566/KSZ9477
> ksz8795.c - KSZ8795/KSZ8795/KSZ8765
> ksz8895.c - KSZ8895/KSZ8864
> ksz8863.c - KSZ8863/KSZ8873
> ksz8463.c - KSZ8463
> 
> These chips have different SPI access mechanisms, MIB counter reading,
> and register set.  These can be combined into one single driver using
> function pointers, at least for ksz8795/ksz8895/ksz8863/ksz8463.  My
> only concern is the memory footprint.  The customer may not want a
> big driver to cover all the switches while only one is used.
> 
> Out of topic I have a question to ask the community regarding the DSA
> port creation:
> 
> Port 1 can be specified using the reg parameter specifying 0; port 2, 1;
> and so on.  The KSZ8794 is a variant of KSZ8795 with port 4 disabled.
> So
> lan1 = 0, lan2 = 1, lan3 = 2, cpu = 4.
> But our company Marketing does not want to promote that fact but treat
> KSZ8794 as a distinct product.
> So
> lan1 = 0, lan2 = 1, lan3 = 2, cpu = 3.
> Is this okay to hide this information inside the driver?  This is manageable
> for KSZ8794 but for KSZ8864 the first port is disabled:
> lan1 = 1, lan2 = 2, lan3 = 3, cpu = 4.

What dictates all of that is ultimately Device Tree because it defines
the port mapping, including where the CPU port is. Once your driver
knows which chip it is "talking to" you could always have the driver
issue warnings and indicate that the Device Tree is malformed if the
user-specified port mapping does not match what the HW supports.

> 
> I am not sure whether DSA has or will have a way to display the port
> mapping to regular users.

DSA does display the port mapping of user facing ports under the
standard sysfs attribute /sys/class/net/*/phys_port_name. CPU port
mapping is not displayed because there is no CPU-port network device
(intentionally).
-- 
Florian
