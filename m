From: Sebastian Frias <sf84@laposte.net>
Subject: Re: [PATCH net-next v2 2/4] Documentation: net: phy: Add a paragraph
 about pause frames/flow control
Date: Wed, 30 Nov 2016 14:20:27 +0100
Message-ID: <c47507af-2384-62af-f416-1ddd5582cdeb@laposte.net>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-3-f.fainelli@gmail.com>
 <1b7425f7-9183-69d4-76e8-42eefffeb1c6@laposte.net>
 <0a923150-582c-16dc-d14d-11d8a2620871@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpoutz28.laposte.net ([194.117.213.103]:42752 "EHLO
        smtp.laposte.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
        with ESMTP id S1754223AbcK3NUb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 08:20:31 -0500
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout016 (Postfix) with ESMTP id B99D911779E
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:20:28 +0100 (CET)
Received: from smtp.laposte.net (localhost [127.0.0.1])
        by lpn-prd-vrout016 (Postfix) with ESMTP id A6D5D1183C3
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:20:28 +0100 (CET)
Received: from lpn-prd-vrin003 (lpn-prd-vrin003.laposte [10.128.63.4])
        by lpn-prd-vrout016 (Postfix) with ESMTP id 9C11A11779E
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:20:28 +0100 (CET)
Received: from lpn-prd-vrin003 (localhost [127.0.0.1])
        by lpn-prd-vrin003 (Postfix) with ESMTP id 86C1348E1D6
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2016 14:20:28 +0100 (CET)
In-Reply-To: <0a923150-582c-16dc-d14d-11d8a2620871@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28/11/16 18:33, Florian Fainelli wrote:
> On 11/28/2016 02:38 AM, Sebastian Frias wrote:
>> On 27/11/16 19:44, Florian Fainelli wrote:
>>> Describe that the Ethernet MAC controller is ultimately responsible for
>>> dealing with proper pause frames/flow control advertisement and
>>> enabling, and that it is therefore allowed to have it change
>>> phydev->supported/advertising with SUPPORTED_Pause and
>>> SUPPORTED_AsymPause.
>>>
>>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>>> ---
>>>  Documentation/networking/phy.txt | 18 ++++++++++++++++--
>>>  1 file changed, 16 insertions(+), 2 deletions(-)
>>>
>>> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
>>> index 4b25c0f24201..9a42a9414cea 100644
>>> --- a/Documentation/networking/phy.txt
>>> +++ b/Documentation/networking/phy.txt
>>> @@ -127,8 +127,9 @@ Letting the PHY Abstraction Layer do Everything
>>>   values pruned from them which don't make sense for your controller (a 10/100
>>>   controller may be connected to a gigabit capable PHY, so you would need to
>>>   mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
>>> - for these bitfields. Note that you should not SET any bits, or the PHY may
>>> - get put into an unsupported state.
>>> + for these bitfields. Note that you should not SET any bits, except the
>>> + SUPPORTED_Pause and SUPPORTED_AsymPause bits (see below), or the PHY may get
>>> + put into an unsupported state.
>>>  
>>>   Lastly, once the controller is ready to handle network traffic, you call
>>>   phy_start(phydev).  This tells the PAL that you are ready, and configures the
>>> @@ -139,6 +140,19 @@ Letting the PHY Abstraction Layer do Everything
>>>   When you want to disconnect from the network (even if just briefly), you call
>>>   phy_stop(phydev).
>>>  
>>> +Pause frames / flow control
>>> +
>>> + The PHY does not participate directly in flow control/pause frames except by
>>> + making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
>>> + MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
>>> + controller supports such a thing. Since flow control/pause frames generation
>>> + involves the Ethernet MAC driver, it is recommended that this driver takes care
>>> + of properly indicating advertisement and support for such features by setting
>>> + the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
>>> + either before or after phy_connect() 
>>
>> If the bits are set after phy_connect(), how does the PHY framework knows there's
>> an update to the bits? Should some call be made?
> 
> You would most likely either call phy_start() to start the PHY state
> machine (again) or have to re-negotiate the link with e.g:
> genphy_restart_aneg().
> 

Thanks, I think that would be worth adding to the documentation, right?
