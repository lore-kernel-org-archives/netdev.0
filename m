From: Dan Murphy <dmurphy@ti.com>
Subject: Re: [PATCH] net: phy: DP83822 initial driver submission
Date: Wed, 4 Oct 2017 10:41:42 -0500
Message-ID: <86fdd4ac-428c-16a4-2b07-fe67765c6f13@ti.com>
References: <20171003155316.12312-1-dmurphy@ti.com>
 <1847c902-8364-3c7c-f079-3d123ba1d3f1@gmail.com>
 <ccab5880-eace-503c-d325-d20867b98bd5@ti.com>
 <fd7379ac-d617-1fed-45a2-6698256cf160@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Florian Fainelli <f.fainelli@gmail.com>, <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fllnx210.ext.ti.com ([198.47.19.17]:54289 "EHLO
        fllnx210.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752458AbdJDPlv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Oct 2017 11:41:51 -0400
In-Reply-To: <fd7379ac-d617-1fed-45a2-6698256cf160@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian

On 10/03/2017 01:31 PM, Florian Fainelli wrote:
> On 10/03/2017 11:03 AM, Dan Murphy wrote:
>> Florian
>>
>> Thanks for the review
>>
>> On 10/03/2017 12:15 PM, Florian Fainelli wrote:
>>>> +		} else {
>>>> +			value &= ~DP83822_WOL_SECURE_ON;
>>>> +		}
>>>> +
>>>> +		value |= (DP83822_WOL_EN | DP83822_WOL_CLR_INDICATION |
>>>> +			  DP83822_WOL_CLR_INDICATION);
>>>
>>> The extra parenthesis should not be required here.
>>
>> I did not code that in.  I had to add it after Checkpatch cribbed about it.
>> Let me know if you want me to remove it.
> 
> Let's keep those, that does not change much.
> 
>>
>>>
>>>> +		phy_write_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG,
>>>> +			      value);
>>>> +	} else {
>>>> +		value =
>>>> +		    phy_read_mmd(phydev, DP83822_DEVADDR, MII_DP83822_WOL_CFG);
>>>> +		value &= (~DP83822_WOL_EN);
>>>
>>> Same here, parenthesis should not be needed.
>>
>> There are three lines of code in the else.  This code all needs to be excuted in the else case.
>> I might reformat it to read better.  Lindent messed that one up.
> 
> sorry, I meant to write that you don't need the parenthesis around
> DP83822_WOL_EN since that is just a single bit here.
> 
> [snip]
> 
>>>> +
>>>> +	mutex_unlock(&phydev->lock);
>>>> +
>>>> +	return 0;
>>>> +}
>>>> +
>>>> +static int dp83822_resume(struct phy_device *phydev)
>>>> +{
>>>> +	int value;
>>>> +
>>>> +	mutex_lock(&phydev->lock);
>>>> +
>>>> +	value = phy_read(phydev, MII_BMCR);
>>>> +	phy_write(phydev, MII_BMCR, value & ~BMCR_PDOWN);
>>>
>>> And genphy_resume() here as well?
>>
>> genphy_resume does not have WoL.
> 
> I should have been cleared, I meant using genphy_{suspend,resume} to
> avoid open coding the setting of the BMCR_PDOWN bit, conversely clearing
> of that bit. Because of the locking, maybe you could introduce unlocked
> versions of these two routines, or you acquire and release the lock
> outside of genphy_{suspend,resume}?

OK I have addressed all of the open comments and will be posting v2 shortly.

I do have a question on this request.
Are you indicating to exclusively call genphy_(suspend/resume) from within the over ridden
routine and then take care of the WoL bits in the phy specific code?

Since the genphy code is duplicated here for the BMCR value that would make the most sense
to me.  The genphy code is exported so I can call it explicitly then do the WoL 

Dan

[snip]-- 
------------------
Dan Murphy
