From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next] net: phy: marvell: Add support for 88e1545 PHY
Date: Thu, 2 Feb 2017 21:19:16 +0300
Message-ID: <c451efad-200f-dd55-c8bc-7d2b17182d1b@cogentembedded.com>
References: <1485992103-23331-1-git-send-email-andrew@lunn.ch>
 <c9fb2430-d42b-0306-084d-6af2fb763fdf@cogentembedded.com>
 <20170202131741.GJ4967@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f43.google.com ([209.85.215.43]:35920 "EHLO
        mail-lf0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750924AbdBBSTT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Feb 2017 13:19:19 -0500
Received: by mail-lf0-f43.google.com with SMTP id z134so13042740lff.3
        for <netdev@vger.kernel.org>; Thu, 02 Feb 2017 10:19:19 -0800 (PST)
In-Reply-To: <20170202131741.GJ4967@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/02/2017 04:17 PM, Andrew Lunn wrote:

>>> The 88e1545 PHYs are discrete Marvell PHYs, found in a quad package on
>>> the zii-devel-b board. Add support for it to the Marvell PHY driver.
>>>
>>> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
>>> ---
>>>
>>> NOTE: To apply cleanly, the "Work around missing PHY product ID in mv88e6390"
>>> patches need to be applied first.
>>>
>>> drivers/net/phy/marvell.c   | 21 +++++++++++++++++++++
>>> include/linux/marvell_phy.h |  1 +
>>> 2 files changed, 22 insertions(+)
>>>
>>> diff --git a/drivers/net/phy/marvell.c b/drivers/net/phy/marvell.c
>>> index 1a0ac48cbc50..f9d0fa315a47 100644
>>> --- a/drivers/net/phy/marvell.c
>>> +++ b/drivers/net/phy/marvell.c
>>> @@ -2123,6 +2123,26 @@ static struct phy_driver marvell_drivers[] = {
>>> 		.get_stats = marvell_get_stats,
>>> 	},
>>> 	{
>>> +		.phy_id = MARVELL_PHY_ID_88E1545,
>>> +		.phy_id_mask = MARVELL_PHY_ID_MASK,
>>> +		.name = "Marvell 88E1545",
>>> +		.probe = m88e1510_probe,
>>> +		.remove = &marvell_remove,
>>> +		.features = PHY_GBIT_FEATURES,
>>> +		.flags = PHY_HAS_INTERRUPT,
>>> +		.config_init = &marvell_config_init,
>>> +		.config_aneg = &m88e1510_config_aneg,
>>> +		.read_status = &marvell_read_status,
>>> +		.ack_interrupt = &marvell_ack_interrupt,
>>> +		.config_intr = &marvell_config_intr,
>>> +		.did_interrupt = &m88e1121_did_interrupt,
>>> +		.resume = &genphy_resume,
>>> +		.suspend = &genphy_suspend,
>>> +		.get_sset_count = marvell_get_sset_count,
>>> +		.get_strings = marvell_get_strings,
>>> +		.get_stats = marvell_get_stats,
>>
>>    Using & on some method inits and not using it on others doesn't
>> look very consistent...
>
> Hi Sergei
>
> Very true. I think it has been historically like that, and adding new
> PHYs is mostly a cut/paste operation. With this list getting longer
> all the time, i'm thinking we should start using some macros.
>
> Are you O.K. with the patch as it is, and a follow-up series to follow
> soon?

    I don't care that much. :-)

> 	Thanks
> 		Andrew

MBR, Sergei
