From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Wed, 27 Apr 2016 13:11:09 -0700
Message-ID: <57211CDD.5000903@gmail.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <16806435.OmqP10ba8M@wasted.cogentembedded.com>
 <874mamzw5q.fsf@ketchup.mtl.sfl> <57211D29.2050704@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org, kernel@savoirfairelinux.com
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:35028 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752526AbcD0UN2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:13:28 -0400
Received: by mail-pa0-f43.google.com with SMTP id iv1so23438163pac.2
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 13:13:28 -0700 (PDT)
In-Reply-To: <57211D29.2050704@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/04/16 13:12, Sergei Shtylyov wrote:
> Hello.
> 
> On 04/27/2016 10:30 PM, Vivien Didelot wrote:
> 
>>> Arnd Bergmann asked that get_phy_device() returns either NULL or the
>>> error
>>> value,  not both on error.  Do as he said, return ERR_PTR(-ENODEV)
>>> instead
>>> of NULL when the PHY ID registers read as  all ones.
>>>
>>> Suggested-by: Arnd Bergmann <arnd@arndb.de>
>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>>
>>> ---
>>>   drivers/net/phy/phy_device.c |    2 +-
>>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> Index: net-next/drivers/net/phy/phy_device.c
>>> ===================================================================
>>> --- net-next.orig/drivers/net/phy/phy_device.c
>>> +++ net-next/drivers/net/phy/phy_device.c
>>> @@ -529,7 +529,7 @@ struct phy_device *get_phy_device(struct
>>>
>>>       /* If the phy_id is mostly Fs, there is no device there */
>>>       if ((phy_id & 0x1fffffff) == 0x1fffffff)
>>> -        return NULL;
>>> +        return ERR_PTR(-ENODEV);
>>>
>>>       return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
>>>   }
>>
>> This particular commit, merged as:
>>
>>      b74766a0a0fe ("phylib: don't return NULL from get_phy_device()")
>>
>> breaks my 3-switch DSA setup with the following error:
>>
>>      fec: probe of 400d1000.ethernet failed with error -22
>>
>> Reverting c971c0e580a6 ("Merge branch 'get_phy_device-retval'") restores
>> a working setup.
> 
>    I think I was able to follow this to the get_phy_device() call in
> fixed_phy_register() but I'm unable to see why it fails now and didn't
> before. Are you using fixed_phy.c at all?

I am using fixed_phy.c and yes, this fails for me too, sorry for not
catching that when you posted the patches :/

-- 
Florian
