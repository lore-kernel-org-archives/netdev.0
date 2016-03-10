From: Murali Karicheri <m-karicheri2@ti.com>
Subject: Re: Micrel Phy - Is there a way to configure the Phy not to do 802.3x
 flow control?
Date: Thu, 10 Mar 2016 14:38:53 -0500
Message-ID: <56E1CD4D.20405@ti.com>
References: <56D8B83E.7000303@ti.com> <56D8D3D7.6070900@gmail.com>
 <56E1A55F.3090906@ti.com> <56E1B75F.9070100@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: Florian Fainelli <f.fainelli@gmail.com>, <johan@kernel.org>,
	"open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>,
	"Kwok, WingMan" <w-kwok2@ti.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bear.ext.ti.com ([192.94.94.41]:43278 "EHLO bear.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752795AbcCJTix (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Mar 2016 14:38:53 -0500
In-Reply-To: <56E1B75F.9070100@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 03/10/2016 01:05 PM, Florian Fainelli wrote:
> On 10/03/16 08:48, Murali Karicheri wrote:
>> On 03/03/2016 07:16 PM, Florian Fainelli wrote:
>>> On 03/03/16 14:18, Murali Karicheri wrote:
>>>> Hi,
>>>>
>>>> We are using Micrel Phy in one of our board and wondering if we can force the
>>>> Phy to disable flow control at start. I have a 1G ethernet switch connected
>>>> to Phy and the phy always enable flow control. I would like to configure the
>>>> phy not to flow control. Is that possible and if yes, what should I do in the
>>>> my Ethernet driver to tell the Phy not to enable flow control?
>>>
>>> The PHY is not doing flow control per-se, your pseudo Ethernet MAC in
>>> the switch is doing, along with the link partner advertising support for
>>> it. You would want to make sure that your PHY device interface (provided
>>> that you are using the PHY library) is not starting with Pause
>>> advertised, but it could be supported.
>>
>> Understood that Phy is just advertise FC. The Micrel phy for 9031 advertise
>> by default FC supported. After negotiation, I see that Phylib provide the 
>> link status with parameter pause = 1, asym_pause = 1. How do I tell the Phy not
>> to advertise?
>>
>> I call following sequence in the Ethernet driver.
>>
>> of_phy_connect(x,y,hndlr,a,z);
> 
> Here you should be able to change phydev->advertising and
> phydev->supported to mask the ADVERTISED_Pause | ADVERTISED_AsymPause
> bits and have phy_start() restart with that which should disable pause
> and asym_pause as seen by your adjust_link handler.
> 
Ok. Good point. I will try this. Thanks for your suggestion.

Murali
>> phy_start()
>>
>> Now in hndlr() I have pause = 1, asym_pause = 1, in phy_device ptr. How can 
>> I tell the phy not to advertise initially?


-- 
Murali Karicheri
Linux Kernel, Keystone
