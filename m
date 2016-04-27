From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH 1/5] phylib: don't return NULL from get_phy_device()
Date: Wed, 27 Apr 2016 23:12:25 +0300
Message-ID: <57211D29.2050704@cogentembedded.com>
References: <56219623.1S7UfcqQqc@wasted.cogentembedded.com>
 <16806435.OmqP10ba8M@wasted.cogentembedded.com>
 <874mamzw5q.fsf@ketchup.mtl.sfl>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: arnd@arndb.de, Andrew Lunn <andrew@lunn.ch>,
	netdev@vger.kernel.org, kernel@savoirfairelinux.com
To: Vivien Didelot <vivien.didelot@savoirfairelinux.com>,
	"David S. Miller" <davem@davemloft.net>, f.fainelli@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f48.google.com ([209.85.215.48]:36593 "EHLO
	mail-lf0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752550AbcD0UM3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 16:12:29 -0400
Received: by mail-lf0-f48.google.com with SMTP id u64so62394735lff.3
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 13:12:28 -0700 (PDT)
In-Reply-To: <874mamzw5q.fsf@ketchup.mtl.sfl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 04/27/2016 10:30 PM, Vivien Didelot wrote:

>> Arnd Bergmann asked that get_phy_device() returns either NULL or the error
>> value,  not both on error.  Do as he said, return ERR_PTR(-ENODEV) instead
>> of NULL when the PHY ID registers read as  all ones.
>>
>> Suggested-by: Arnd Bergmann <arnd@arndb.de>
>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
>>
>> ---
>>   drivers/net/phy/phy_device.c |    2 +-
>>   1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> Index: net-next/drivers/net/phy/phy_device.c
>> ===================================================================
>> --- net-next.orig/drivers/net/phy/phy_device.c
>> +++ net-next/drivers/net/phy/phy_device.c
>> @@ -529,7 +529,7 @@ struct phy_device *get_phy_device(struct
>>
>>   	/* If the phy_id is mostly Fs, there is no device there */
>>   	if ((phy_id & 0x1fffffff) == 0x1fffffff)
>> -		return NULL;
>> +		return ERR_PTR(-ENODEV);
>>
>>   	return phy_device_create(bus, addr, phy_id, is_c45, &c45_ids);
>>   }
>
> This particular commit, merged as:
>
>      b74766a0a0fe ("phylib: don't return NULL from get_phy_device()")
>
> breaks my 3-switch DSA setup with the following error:
>
>      fec: probe of 400d1000.ethernet failed with error -22
>
> Reverting c971c0e580a6 ("Merge branch 'get_phy_device-retval'") restores
> a working setup.

    I think I was able to follow this to the get_phy_device() call in 
fixed_phy_register() but I'm unable to see why it fails now and didn't before. 
Are you using fixed_phy.c at all?

> Thanks,
>
>          Vivien

MBR, Sergei
