From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/2] dl2k: Add support for IP1000A-based cards
Date: Sun, 15 Nov 2015 12:59:05 -0500 (EST)
Message-ID: <20151115.125905.63907005203700143.davem@davemloft.net>
References: <1447538738-28605-1-git-send-email-linux@rainbow-software.org>
	<CAHp75VehDXoMNsXD08Et9Z5Pds+7Xf5+PXHE2pFzh4Srs-Tw+A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux@rainbow-software.org, netdev@vger.kernel.org,
	romieu@fr.zoreil.com, linux-kernel@vger.kernel.org
To: andy.shevchenko@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CAHp75VehDXoMNsXD08Et9Z5Pds+7Xf5+PXHE2pFzh4Srs-Tw+A@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andy Shevchenko <andy.shevchenko@gmail.com>
Date: Sun, 15 Nov 2015 04:30:25 +0200

> On Sun, Nov 15, 2015 at 12:05 AM, Ondrej Zary
>> @@ -433,9 +474,10 @@ rio_open (struct net_device *dev)
>>
>>         alloc_list (dev);
>>
>> -       /* Get station address */
>> -       for (i = 0; i < 6; i++)
>> -               dw8(StationAddr0 + i, dev->dev_addr[i]);
>> +       /* Set station address */
>> +       for (i = 0; i < 3; i++)
>> +               dw16(StationAddr0 + 2 * i,
>> +                    cpu_to_le16(((u16 *)dev->dev_addr)[i]));
> 
> Is it specific requirement for new HW? If not, may be another patch
> with micro optimizations.

I absolutely agree, this definitely should not just be blindly copied
over from the other driver.

And if it is a requirement:

1) It must be documented as per why, both in a comment above the loop
   and in the commit log message.

2) It must therefore be tested on dl2k chips that worked with the
   dl2k driver beforehand to prove that it doesn't break them.
