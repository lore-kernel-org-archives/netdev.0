From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH v2] net: phy: micrel: add support for KSZ8795
Date: Fri, 27 Jan 2017 12:19:44 -0800
Message-ID: <523deaac-0aa4-740b-43cd-b8cd41961395@gmail.com>
References: <20170127074623.9200-1-sean.nyekjaer@prevas.dk>
 <bce20c23-0d67-128b-3643-2aafc3648e68@gmail.com>
 <7ce764a4-5dd9-bb97-55e3-2317d0967326@prevas.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: andrew@lunn.ch
To: =?UTF-8?Q?Sean_Nyekj=c3=a6r?= <sean.nyekjaer@prevas.dk>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f196.google.com ([209.85.192.196]:35600 "EHLO
        mail-pf0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750978AbdA0UTx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 15:19:53 -0500
Received: by mail-pf0-f196.google.com with SMTP id f144so19188743pfa.2
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2017 12:19:46 -0800 (PST)
In-Reply-To: <7ce764a4-5dd9-bb97-55e3-2317d0967326@prevas.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/27/2017 11:52 AM, Sean Nyekjær wrote:
> 
> 
> On 2017-01-27 19:55, Florian Fainelli wrote:
>> On 01/26/2017 11:46 PM, Sean Nyekjaer wrote:
>>> This is adds support for the PHYs in the KSZ8795 5port managed switch.
>>>
>>> It will allow to detect the link between the switch and the soc
>>> and uses the same read_status functions as the KSZ8873MLL switch.
>>>
>>> Signed-off-by: Sean Nyekjaer <sean.nyekjaer@prevas.dk>
>>> ---
>>> Changes in v2:
>>>   - Removed "switch" name
>>>
>>>   drivers/net/phy/micrel.c   | 14 ++++++++++++++
>>>   include/linux/micrel_phy.h |  2 ++
>>>   2 files changed, 16 insertions(+)
>>>
>>> diff --git a/drivers/net/phy/micrel.c b/drivers/net/phy/micrel.c
>>> index ea92d524d5a8..fab56c9350cf 100644
>>> --- a/drivers/net/phy/micrel.c
>>> +++ b/drivers/net/phy/micrel.c
>>> @@ -1014,6 +1014,20 @@ static struct phy_driver ksphy_driver[] = {
>>>       .get_stats    = kszphy_get_stats,
>>>       .suspend    = genphy_suspend,
>>>       .resume        = genphy_resume,
>>> +}, {
>>> +    .phy_id        = PHY_ID_KSZ8795,
>>> +    .phy_id_mask    = MICREL_PHY_ID_MASK,
>>> +    .name        = "Micrel KSZ8795",
>>> +    .features    = (SUPPORTED_Pause | SUPPORTED_Asym_Pause),
>> This is wrong, it should be PHY_GBIT_FEATURES or PHY_BASIC_FEATURES.
>> Including the Pause/AsymPause feature bits is not longer necessary, the
>> PHY library takes care of adding these automatically to let your MAC do
>> flow control auto-negotiation later on.
>>
>> Please submit an incremental fix to that.
> By this you mean a v3 or a new commit?

Incremental means a new commit here, on top of this patch right here.
-- 
Florian
