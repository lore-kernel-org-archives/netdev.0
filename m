From: Phil Reid <preid@electromag.com.au>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode is
 not found in the DTS
Date: Fri, 8 Jan 2016 09:00:09 +0800
Message-ID: <568F0A19.7010208@electromag.com.au>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>
 <0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>
 <CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>
 <56880E46.4050206@gmail.com>
 <CABgxDo+EOVW-RJ1WVY+oHt1tbW7qq9Q_+wK3ywiexh+auEebaA@mail.gmail.com>
 <568EC072.6050803@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from anchovy3.45ru.net.au ([203.30.46.155]:39940 "EHLO
	anchovy.45ru.net.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753498AbcAHBAM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 20:00:12 -0500
In-Reply-To: <568EC072.6050803@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/01/2016 3:45 AM, Florian Fainelli wrote:
> On 03/01/16 06:36, Romain Perier wrote:
>> Hi,
>>
>> 2016-01-02 18:52 GMT+01:00 Florian Fainelli <f.fainelli@gmail.com>:
>>>
>>>>> This looks reasonable, does it work if we just assign mdio_node to the pdev->dev.of_node to be backwards compatible with DTSes which have not yet been updated?
>>>>>
>>>>
>>>> I don't understand what you mean. Instead of defining mdio_node with
>>>> NULL, you propose to assign it to pdev->dev.of_node as its default
>>>> value... then it would be reassigned with "child_nod" if a subnode
>>>> with the compatible string "snps,dwmac-mdio" is found, or kept with
>>>> its default value otherwise... and in this case we could call
>>>> of_mdiobus_register(new_bus, mdio_node) all the time ? (it removes the
>>>> conditonnal branch)
>>>
>>> Your understanding is correct, this is what I was suggesting, thanks
>>
>> So in this case, I already tested this yesterday, it does not work,
>> basically because the for loop just after of_mdiobus_register is never
>> executed, probably because new_bus->phy_map is not populated, which is
>> not the case by calling mdiobus_register for example.
>> of_mdiobus_register seems to populate this array of phys only for
>> subnodes found in the devicetree...
>
> Fair enough, then you initial patch with dropping IS_ENABLED() and
> adding a "Fixes" tag should be resubmitted.
>
Looks reasonable.



-- 
Regards
Phil Reid
