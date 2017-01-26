From: =?UTF-8?Q?Sean_Nyekj=c3=a6r?= <sean.nyekjaer@prevas.dk>
Subject: Re: [PATCH v1] net: phy: micrel: add KSZ8795 ethernet switch
Date: Thu, 26 Jan 2017 18:51:07 +0100
Message-ID: <732c14ff-f0cf-67d5-bcf9-cbbf9a4391b3@prevas.dk>
References: <20170123075846.12888-1-sean.nyekjaer@prevas.dk>
 <20170123151219.GE10895@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail02.prevas.se ([62.95.78.10]:13469 "EHLO mail02.prevas.se"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752183AbdAZSH4 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 26 Jan 2017 13:07:56 -0500
In-Reply-To: <20170123151219.GE10895@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On 2017-01-23 16:12, Andrew Lunn wrote:
> On Mon, Jan 23, 2017 at 08:58:46AM +0100, Sean Nyekjaer wrote:
>> This is add support for the PHYs in the KSZ8795 5port managed switch.
>>
>> It will allow to detect the link between the switch and the soc
>> and uses the same read_status functions as the KSZ8873MLL switch.
>>
>> This ethernet switch have unfortunately the same phy id as KSZ8051.
>>
>> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
>> ---
>>   drivers/net/phy/micrel.c   | 14 ++++++++++++++
>>   include/linux/micrel_phy.h |  2 ++
>>   2 files changed, 16 insertions(+)
>>
>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>> index ea92d524d5a8..fa158ae5115b 100644
>> --- a/drivers/net/phy/micrel.c
>> +++ b/drivers/net/phy/micrel.c
>> @@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
>>   	.get_stats	= kszphy_get_stats,
>>   	.suspend	= genphy_suspend,
>>   	.resume		= genphy_resume,
>> +}, {
>> +	.phy_id		= PHY_ID_KSZ8795,
>> +	.phy_id_mask	= MICREL_PHY_ID_MASK,
>> +	.name		= "Micrel KSZ8795 Switch",
> This name is confusing. You are adding support for the PHYs embedded
> in the switch, not the switch itself. The phylib has no idea these
> PHYs are inside a switch. It does not matter. It is just a PHY. Please
> drop the word "Switch".
>
> Thanks
> 	Andrew
Okay i'll understand :-)
I remove the word "Switch" from the commit message and phy name.
The rest is okay?
What is generally being done when to phy's have the same id, micrel have 
done this many times...

/Sean
