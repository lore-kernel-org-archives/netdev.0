From: Andy Fleming <afleming@freescale.com>
Subject: Re: [RFC] Change mii_bus id field to a string
Date: Thu, 3 Apr 2008 15:19:00 -0500
Message-ID: <2D4CFB4B-D8AD-4DF1-A7F0-EFD7C90F1F0E@freescale.com>
References: <1207176592-4224-1-git-send-email-afleming@freescale.com> <20080403192603.GM21637@solarflare.com>
Mime-Version: 1.0 (Apple Message framework v919.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ncase@xes-inc.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from az33egw02.freescale.net ([192.88.158.103]:34442 "EHLO
	az33egw02.freescale.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750758AbYDCUTK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Apr 2008 16:19:10 -0400
In-Reply-To: <20080403192603.GM21637@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Apr 3, 2008, at 14:26, Ben Hutchings wrote:

> Andy Fleming wrote:
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index 5e43ae7..92a4829 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -63,8 +63,6 @@ typedef enum {
>> 	PHY_INTERFACE_MODE_RTBI
>> } phy_interface_t;
>>
>> -#define MII_BUS_MAX 4
>> -
>>
>> #define PHY_INIT_TIMEOUT	100000
>> #define PHY_STATE_TIME		1
>> @@ -74,20 +72,30 @@ typedef enum {
>> #define PHY_MAX_ADDR	32
>>
>> /* Used when trying to connect to a specific phy (mii bus id:phy  
>> device id) */
>> -#define PHY_ID_FMT "%x:%02x"
>> +#define PHY_ID_FMT "%s:%02x"
>> +
>> +/*
>> + * Need to be a little smaller than phydev->dev.bus_id to leave room
>> + * for the ":%02x"
>> + */
>> +#define MII_BUS_ID_SIZE	BUS_ID_SIZE - 3
>
> The macro's definition should be parenthesised.

Agreed.

>
>
>>
>> -/* The Bus class for PHYs.  Devices which provide access to
>> - * PHYs should register using this structure */
>> +/*
>> + * The Bus class for PHYs.  Devices which provide access to
>> + * PHYs should register using this structure
>> + */
>
> I'm not sure why you reformatted this and other comments.  If you  
> really
> think it's necessary to do that, you should probably post a separate  
> patch
> rather than combining it with this functional change.


I reformatted them because the coding standards call for them to be  
formatted differently.  I was aware of that when I wrote them, so I'm  
not sure why I left them like that.  I combined them with this patch  
due to laziness.  I'll separate them out when I resubmit.

Andy
