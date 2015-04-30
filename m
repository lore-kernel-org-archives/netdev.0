From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [RFC PATCH net-next 3/8] net: phy: Allow PHY devices to identify
 themselves as Ethernet switches
Date: Thu, 30 Apr 2015 09:39:15 -0700
Message-ID: <55425AB3.2040908@gmail.com>
References: <1430359064-23454-1-git-send-email-f.fainelli@gmail.com> <1430359064-23454-4-git-send-email-f.fainelli@gmail.com> <20150430125658.GB22831@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	vivien.didelot@savoirfairelinux.com,
	jerome.oufella@savoirfairelinux.com, linux@roeck-us.net,
	cphealy@gmail.com, mathieu@codeaurora.org, jonasj76@gmail.com,
	andrey.volkov@nexvision.fr, Chris.Packham@alliedtelesis.co.nz
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:36534 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751031AbbD3QjV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Apr 2015 12:39:21 -0400
Received: by pdea3 with SMTP id a3so65745714pde.3
        for <netdev@vger.kernel.org>; Thu, 30 Apr 2015 09:39:21 -0700 (PDT)
In-Reply-To: <20150430125658.GB22831@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 30/04/15 05:56, Andrew Lunn wrote:
> On Wed, Apr 29, 2015 at 06:57:39PM -0700, Florian Fainelli wrote:
>> Some Ethernet MAC drivers using the PHY library require the hardcoding
>> of link parameters when interfaced to a switch device. This has
>> typically lead to various ad-hoc implementations looking like this:
>>
>> - using a "fixed PHY" emulated device, which will provide link
>>   indication towards the Ethernet MAC driver and hardware
>>
>> - pretend there is no PHY and hardcode link parameters, ala mv643x_eth
>>
>> Based on that, it is desireable to have the PHY drivers advertise the
>> correct link parameters, just like regular Ethernet PHYs towards their
>> CPU Ethernet MAC drivers, however, Ethernet MAC drivers should be able
>> to tell whether this link should be monitored or not. In the context of
>> an Ethernet switch, we do not need to monitor this link since it should
>> be always up.
>>
>> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
>> ---
>>  include/linux/phy.h | 12 ++++++++++++
>>  1 file changed, 12 insertions(+)
>>
>> diff --git a/include/linux/phy.h b/include/linux/phy.h
>> index 685809835b5c..52fc64874fdb 100644
>> --- a/include/linux/phy.h
>> +++ b/include/linux/phy.h
>> @@ -327,6 +327,7 @@ struct phy_c45_device_ids {
>>   * c45_ids: 802.3-c45 Device Identifers if is_c45.
>>   * is_c45:  Set to true if this phy uses clause 45 addressing.
>>   * is_internal: Set to true if this phy is internal to a MAC.
>> + * is_switch: Set to true if this phy is an Ethernet switch.
>>   * has_fixups: Set to true if this phy has fixups/quirks.
>>   * suspended: Set to true if this phy has been suspended successfully.
>>   * state: state of the PHY for management purposes
>> @@ -365,6 +366,7 @@ struct phy_device {
>>  	struct phy_c45_device_ids c45_ids;
>>  	bool is_c45;
>>  	bool is_internal;
>> +	bool is_switch;
> 
> Hi Florian
> 
> I have another two use cases for fixed_phy which i'm thinking about
> implementing soon. Both require putting a fixed_phy into DSA port
> properties in DT.
> 
> The first is when the CPU ethernet and the switch don't have the same
> speed capabilities. At the moment, the switch driver configures the
> CPU port to its maximum speed. But i know of a board coming soon with
> gigabit switch ports, but the CPU Ethernet is only fast Ethernet.

With the patch after, if your switch is MDIO connected to your host, you
could make that happen easily, since the read_status() callback would
only be invoked for the CPU port from the CPU Ethernet MAC driver
(that's the theory).

> 
> When switch ports are connected to an SFP module, not a copper phy. A
> fixed phy allows the switch to be configured to the correct
> speed/duplex to match the SFP module.

Ok, but not these cases though.

> 
> So in this respect, i'm wondering if is_switch is the best of names?

Probably not, I agree, pseudo_fixed_link ;)?
--
Florian
