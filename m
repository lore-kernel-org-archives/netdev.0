From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH RFC] Update documentation for KSZ DSA drivers so that new
 drivers can be added
Date: Fri, 8 Sep 2017 12:05:35 -0700
Message-ID: <7de95a6f-5953-5f32-4903-a83441418099@gmail.com>
References: <93AF473E2DA327428DE3D46B72B1E9FD41121A5B@CHN-SV-EXMX02.mchp-main.com>
 <20170907215417.GU11248@lunn.ch>
 <CAJGZr0+r3UhhRJcGXvBKZGamrSH_XEQY5oo7MTBjTTrDFOiKtg@mail.gmail.com>
 <20170908141225.GE25219@lunn.ch>
 <93AF473E2DA327428DE3D46B72B1E9FD41121E68@CHN-SV-EXMX02.mchp-main.com>
 <20170908190122.GM25219@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: muvarov@gmail.com, pavel@ucw.cz, nathan.leigh.conrad@gmail.com,
        vivien.didelot@savoirfairelinux.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, Woojung.Huh@microchip.com
To: Andrew Lunn <andrew@lunn.ch>, Tristram.Ha@microchip.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170908190122.GM25219@lunn.ch>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/08/2017 12:01 PM, Andrew Lunn wrote:
>>> So i would suggest one driver supporting all the different devices.
>>
>> There will be 5 drivers to support these devices:
>>
>> ksz9477.c - KSZ9893/KSZ9897/KSZ9567/KSZ9566/KSZ9477
>> ksz8795.c - KSZ8795/KSZ8795/KSZ8765
>> ksz8895.c - KSZ8895/KSZ8864
>> ksz8863.c - KSZ8863/KSZ8873
>> ksz8463.c - KSZ8463
>>
>> These chips have different SPI access mechanisms, MIB counter reading,
>> and register set.  These can be combined into one single driver using
>> function pointers, at least for ksz8795/ksz8895/ksz8863/ksz8463.  My
>> only concern is the memory footprint.  The customer may not want a
>> big driver to cover all the switches while only one is used.
> 
> If memory footprint is your problem, make it a compile time choice
> which devices are supported within the one driver. In practice, you
> will find most distributions just enable them all.
>  
>> Out of topic I have a question to ask the community regarding the DSA
>> port creation:
>>
>> Port 1 can be specified using the reg parameter specifying 0; port 2, 1;
>> and so on.  The KSZ8794 is a variant of KSZ8795 with port 4 disabled.
>> So
>> lan1 = 0, lan2 = 1, lan3 = 2, cpu = 4.
>> But our company Marketing does not want to promote that fact but treat
>> KSZ8794 as a distinct product.
>> So
>> lan1 = 0, lan2 = 1, lan3 = 2, cpu = 3.
>> Is this okay to hide this information inside the driver?  This is manageable
>> for KSZ8794 but for KSZ8864 the first port is disabled:
>> lan1 = 1, lan2 = 2, lan3 = 3, cpu = 4.
>>
>> I am not sure whether DSA has or will have a way to display the port
>> mapping to regular users.
> 
> So the port number to name is determined in the device tree. It
> depends on the board how the ports are named. I always suggest going
> by the label on the box. clearfog is a good example of this, 0 - lan5,
> 1 - lan4, etc.
> 
> So for the KSZ8864, ensure reg = 0 causes an error.
> 
> Does the hardware force which port is used for the CPU? I've boards
> with Marvell devices where the CPU is port 0, or port 6, or port
> 7. The hardware does not care. So we don't force anything.
> 
> As for KSZ8794 vs KSZ8795, is there different IDs in the silicon?  It
> is these IDs you are using, not the compatible string, to determine
> how the drive the silicon. You can trust the ID in the
> silicon. Anything else can be wrong.

You can't always trust the silicon to report the right revision, just
like marketing people in semiconductors tend to like to play tricks and
pretend that the same chip is the same, but it is not quite, and a new
tape-out was not possible, so it has the same ID, including the
revision. This is of course not what should be done, but it happens all
the time.

Describe in Device Tree with a proper compatible string, which may
end-up being treated the same way by the driver, and if it happens that
the silicon is not wrong, and can be differentiated, then you can always
resort to that to warn the user the wrong compatible was specified, or
that this is not going to work, or anything really.
-- 
Florian
