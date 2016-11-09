From: Tom Lendacky <thomas.lendacky@amd.com>
Subject: Re: [PATCH net-next v1 17/21] amd-xgbe: Add I2C support for
 determining SFP media types
Date: Wed, 9 Nov 2016 09:35:01 -0600
Message-ID: <ab524e5d-c3fd-bb92-6a4e-3aa66c781bc2@amd.com>
References: <20161103132744.3437.27332.stgit@tlendack-t1.amdoffice.net>
 <20161103133036.3437.71231.stgit@tlendack-t1.amdoffice.net>
 <20161103142815.GB1768@lunn.ch>
 <1af561af-65e2-8422-1901-d4b1c317ad12@amd.com>
 <20161103151848.GD1768@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, Florian Fainelli <f.fainelli@gmail.com>,
        David Miller <davem@davemloft.net>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-by2nam01on0078.outbound.protection.outlook.com ([104.47.34.78]:15072
        "EHLO NAM01-BY2-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753824AbcKIPfN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 9 Nov 2016 10:35:13 -0500
In-Reply-To: <20161103151848.GD1768@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/3/2016 10:18 AM, Andrew Lunn wrote:
>> There are a couple of things about this. Russel's work isn't part of
>> the kernel yet so I can't make use of it.
> 
> Well, you could guide it into the kernel. Part of it has already made
> the way in. And i know of other platforms which would benefit from it.
> 
>> Additionally, the I2C device is integrated into the IP of the
>> network device with register addresses being offsets of the network
>> device BAR so I'm not sure how I would go about getting it setup in
>> order to use the i2c infrastructure.
> 
> Have you looked at the core i2c stuff? All you need is an
> i2c_algorithim structure:
> 
> http://lxr.free-electrons.com/source/include/linux/i2c.h#L407
> 
> and an i2c_adaptor structure:
> 
> http://lxr.free-electrons.com/source/include/linux/i2c.h#L532
> 
> and then you can call i2c_add_adapter() to register your i2c bus with
> the i2c core. Embedded such an i2c driver inside another driver is not
> a problem.

I looked into this but I need to investigate this more. The I2C bus
for this device is dedicated to multiple instances of this device which
requires obtaining a hardware mutex before using it. I see how the
locking is done, but I might need additional mutexes to protect certain
scenarios and it could affect performance if I have to obtain and
release the hardware mutex more than is needed.

I'd like to stay with what I have for now in order to enable the driver
and then come back and look at what it would take to integrate this
support into the driver knowing that userspace could be accessing the
bus, also.

Thanks,
Tom

> 
>   Andrew
> 
