From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [PATCH net-next v2 2/4] Documentation: net: phy: Add a paragraph
 about pause frames/flow control
Date: Mon, 28 Nov 2016 09:33:34 -0800
Message-ID: <0a923150-582c-16dc-d14d-11d8a2620871@gmail.com>
References: <20161127184449.12351-1-f.fainelli@gmail.com>
 <20161127184449.12351-3-f.fainelli@gmail.com>
 <1b7425f7-9183-69d4-76e8-42eefffeb1c6@laposte.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, andrew@lunn.ch,
        martin.blumenstingl@googlemail.com, mans@mansr.com,
        alexandre.torgue@st.com, peppe.cavallaro@st.com,
        timur@codeaurora.org, jbrunet@baylibre.com
To: Sebastian Frias <sf84@laposte.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f67.google.com ([74.125.83.67]:35049 "EHLO
        mail-pg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754136AbcK1Rdh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 12:33:37 -0500
Received: by mail-pg0-f67.google.com with SMTP id p66so13683684pga.2
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 09:33:36 -0800 (PST)
In-Reply-To: <1b7425f7-9183-69d4-76e8-42eefffeb1c6@laposte.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/2016 02:38 AM, Sebastian Frias wrote:
> On 27/11/16 19:44, Florian Fainelli wrote:
>> Describe that the Ethernet MAC controller is ultimately responsible for
>> dealing with proper pause frames/flow control advertisement and
>> enabling, and that it is therefore allowed to have it change
>> phydev->supported/advertising with SUPPORTED_Pause and
>> SUPPORTED_AsymPause.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  Documentation/networking/phy.txt | 18 ++++++++++++++++--
>>  1 file changed, 16 insertions(+), 2 deletions(-)
>>
>> diff --git a/Documentation/networking/phy.txt b/Documentation/networking/phy.txt
>> index 4b25c0f24201..9a42a9414cea 100644
>> --- a/Documentation/networking/phy.txt
>> +++ b/Documentation/networking/phy.txt
>> @@ -127,8 +127,9 @@ Letting the PHY Abstraction Layer do Everything
>>   values pruned from them which don't make sense for your controller (a 10/100
>>   controller may be connected to a gigabit capable PHY, so you would need to
>>   mask off SUPPORTED_1000baseT*).  See include/linux/ethtool.h for definitions
>> - for these bitfields. Note that you should not SET any bits, or the PHY may
>> - get put into an unsupported state.
>> + for these bitfields. Note that you should not SET any bits, except the
>> + SUPPORTED_Pause and SUPPORTED_AsymPause bits (see below), or the PHY may get
>> + put into an unsupported state.
>>  
>>   Lastly, once the controller is ready to handle network traffic, you call
>>   phy_start(phydev).  This tells the PAL that you are ready, and configures the
>> @@ -139,6 +140,19 @@ Letting the PHY Abstraction Layer do Everything
>>   When you want to disconnect from the network (even if just briefly), you call
>>   phy_stop(phydev).
>>  
>> +Pause frames / flow control
>> +
>> + The PHY does not participate directly in flow control/pause frames except by
>> + making sure that the SUPPORTED_Pause and SUPPORTED_AsymPause bits are set in
>> + MII_ADVERTISE to indicate towards the link partner that the Ethernet MAC
>> + controller supports such a thing. Since flow control/pause frames generation
>> + involves the Ethernet MAC driver, it is recommended that this driver takes care
>> + of properly indicating advertisement and support for such features by setting
>> + the SUPPORTED_Pause and SUPPORTED_AsymPause bits accordingly. This can be done
>> + either before or after phy_connect() 
> 
> If the bits are set after phy_connect(), how does the PHY framework knows there's
> an update to the bits? Should some call be made?

You would most likely either call phy_start() to start the PHY state
machine (again) or have to re-negotiate the link with e.g:
genphy_restart_aneg().
-- 
Florian
