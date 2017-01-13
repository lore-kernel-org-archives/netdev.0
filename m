From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next] mii_bus: increase MII_BUS_ID_SIZE to 61
Date: Fri, 13 Jan 2017 10:59:50 -0800
Message-ID: <d0fd8c35-4100-3c63-ab89-85a7f5521b88@gmail.com>
References: <1484320752-32096-1-git-send-email-volodymyr.bendiuga@gmail.com>
 <20170113163108.GN10203@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: netdev@vger.kernel.org, volodymyr.bendiuga@westermo.se,
        =?UTF-8?Q?Magnus_=c3=96berg?= <magnus.oberg@westermo.se>
To: Andrew Lunn <andrew@lunn.ch>,
        Volodymyr Bendiuga <volodymyr.bendiuga@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35450 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750835AbdAMS7x (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 13 Jan 2017 13:59:53 -0500
Received: by mail-pf0-f195.google.com with SMTP id f144so9469050pfa.2
        for <netdev@vger.kernel.org>; Fri, 13 Jan 2017 10:59:52 -0800 (PST)
In-Reply-To: <20170113163108.GN10203@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/13/2017 08:31 AM, Andrew Lunn wrote:
> On Fri, Jan 13, 2017 at 04:19:12PM +0100, Volodymyr Bendiuga wrote:
>> From: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
>>
>> Some bus names are pretty long and do not fit into 20 chars.
>>
>> Signed-off-by: Volodymyr Bendiuga <volodymyr.bendiuga@westermo.se>
>> Signed-off-by: Magnus Öberg <magnus.oberg@westermo.se>
>> ---
>>  include/linux/phy.h | 2 +-
>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index feb8a98..b67f94d 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -162,7 +162,7 @@ static inline const char *phy_modes(phy_interface_t interface)
>>   * Need to be a little smaller than phydev->dev.bus_id to leave room
>>   * for the ":%02x"
>>   */
>> -#define MII_BUS_ID_SIZE	(20 - 3)
>> +#define MII_BUS_ID_SIZE	(64 - 3)
> 
> Hi Volodymyr
> 
> Humm, i assume you looked at the comment? What is the size of phydev->dev.bus_id?
> Is 61 still a little smaller?

Also it seems like you missed this one:

/* A Structure for boards to register fixups with the PHY Lib */
struct phy_fixup {
        struct list_head list;
        char bus_id[20];
	^================
        u32 phy_uid;
        u32 phy_uid_mask;
        int (*run)(struct phy_device *phydev);
};

Did you really run into naming conflicts where increasing the bus ID
size became the only solution here?
-- 
Florian
