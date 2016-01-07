From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH] stmmac: Don't exit mdio registration when mdio subnode
 is not found in the DTS
Date: Thu, 07 Jan 2016 11:45:54 -0800
Message-ID: <568EC072.6050803@gmail.com>
References: <1451397935-23643-1-git-send-email-romain.perier@gmail.com>	<0E6F98A1-B9F1-48B0-B5CA-A215803E827F@gmail.com>	<CABgxDoLNWEtYtRTrYhp7T=tk3n-aPMCgOP2SL7+DoxFqTk7GuQ@mail.gmail.com>	<56880E46.4050206@gmail.com> <CABgxDo+EOVW-RJ1WVY+oHt1tbW7qq9Q_+wK3ywiexh+auEebaA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: peppe.cavallaro@st.com, netdev <netdev@vger.kernel.org>,
	"open list:ARM/Rockchip SoC..." <linux-rockchip@lists.infradead.org>
To: Romain Perier <romain.perier@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:35812 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752580AbcAGTq2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2016 14:46:28 -0500
Received: by mail-pa0-f41.google.com with SMTP id ho8so5375366pac.2
        for <netdev@vger.kernel.org>; Thu, 07 Jan 2016 11:46:28 -0800 (PST)
In-Reply-To: <CABgxDo+EOVW-RJ1WVY+oHt1tbW7qq9Q_+wK3ywiexh+auEebaA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/01/16 06:36, Romain Perier wrote:
> Hi,
> 
> 2016-01-02 18:52 GMT+01:00 Florian Fainelli <f.fainelli@gmail.com>:
>>
>>>> This looks reasonable, does it work if we just assign mdio_node to the pdev->dev.of_node to be backwards compatible with DTSes which have not yet been updated?
>>>>
>>>
>>> I don't understand what you mean. Instead of defining mdio_node with
>>> NULL, you propose to assign it to pdev->dev.of_node as its default
>>> value... then it would be reassigned with "child_nod" if a subnode
>>> with the compatible string "snps,dwmac-mdio" is found, or kept with
>>> its default value otherwise... and in this case we could call
>>> of_mdiobus_register(new_bus, mdio_node) all the time ? (it removes the
>>> conditonnal branch)
>>
>> Your understanding is correct, this is what I was suggesting, thanks
> 
> So in this case, I already tested this yesterday, it does not work,
> basically because the for loop just after of_mdiobus_register is never
> executed, probably because new_bus->phy_map is not populated, which is
> not the case by calling mdiobus_register for example.
> of_mdiobus_register seems to populate this array of phys only for
> subnodes found in the devicetree...

Fair enough, then you initial patch with dropping IS_ENABLED() and
adding a "Fixes" tag should be resubmitted.

Thank you
-- 
Florian
