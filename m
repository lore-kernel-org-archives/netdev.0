From: Hauke Mehrtens <hauke@hauke-m.de>
Subject: Re: [RFC v2 2/2] NET: PHY: lantiq: add LED configuration support
Date: Sat, 28 May 2016 23:23:21 +0200
Message-ID: <574A0C49.1010604@hauke-m.de>
References: <1464454741-18557-1-git-send-email-hauke@hauke-m.de>
 <1464454741-18557-2-git-send-email-hauke@hauke-m.de>
 <20160528182709.GJ23212@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 8bit
Cc: f.fainelli@gmail.com, alexander.stein@systec-electronic.com,
	netdev@vger.kernel.org, john@phrozen.org, openwrt@kresin.me,
	hauke.mehrtens@intel.com, daniel.schwierzeck@gmail.com,
	eckert.florian@googlemail.com
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hauke-m.de ([5.39.93.123]:42470 "EHLO hauke-m.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbcE1VXZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 May 2016 17:23:25 -0400
In-Reply-To: <20160528182709.GJ23212@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/28/2016 08:27 PM, Andrew Lunn wrote:
> On Sat, May 28, 2016 at 06:59:01PM +0200, Hauke Mehrtens wrote:
>> This makes it possible to configure the behavior of the LEDs connected
>> to a PHY. The LEDs are controlled by the chip, this makes it possible
>> to configure the behavior when the hardware should activate and
>> deactivate the LEDs.
>>
>> Signed-off-by: Hauke Mehrtens <hauke@hauke-m.de>
> 
> Hi Hauke
> 
> This is interesting. But you definitely needs to Cc: the device tree
> list.

Ah yes I forgot that, will fix the typos and resend it.

> It would also be good to see basic implementations for other PHYs, so
> we know the binding is generic enough.

Do you know for which PHY I could implement this? I only have access to
the documentation for the Lantiq / Intel PHYs.

>> +LED configuration for Ethernet phys
>> +
>> +Property names:
>> +	led-const-on: conditions the LED should be constant on
>> +	led-pules: condition the LED should be pulsed on
>> +	led-blink-slow: condition the LED should slowly blink
>> +	led-blink-fast: condition the LED should fast blink
> 
> A binding should make it clear if properties are required or optional.

OK, I will make the all optional. Currently my intention was to make
this a generic binding, but different hardware probably has different
capabilities.  Should this documentation file be specific for this PHY
driver or should I add two files for documentation one describing the
generic interface and then an additional one describing the concrete
capabilities of this PHY?

> 
> led-pulse, not led-pules.

will fix that.

> These properties also seem to be mutually exclusive. How can it be
> constantly on, yet blink? You need better descriptions.

This specific phy has an order in which the attributes are applied, I
will document that.

>> +property values:
>> +	PHY_LED_OFF:		LED is off
>> +	PHY_LED_LINK10:		link is 10MBit/s
>> +	PHY_LED_LINK100:	link is 100MBit/s
>> +	PHY_LED_LINK1000:	link is 1000MBit/s
>> +	PHY_LED_PDOWN:		link is powered down
>> +	PHY_LED_EEE:		link is in EEE mode
>> +	PHY_LED_ANEG:		auto negotiation is running
>> +	PHY_LED_ABIST:		analog self testing is running
>> +	PHY_LED_CDIAG:		cable diagnostics is running
>> +	PHY_LED_COPPER:		copper interface detected
>> +	PHY_LED_FIBER:		fiber interface detected
>> +	PHY_LED_TXACT:		Transmit activity
>> +	PHY_LED_RXACT:		Receive activity
>> +	PHY_LED_COL:		Collision
> 
> There should be a comment that not all PHYs implement all values, or
> even all properties. And some PHYS will accept an ORed list of
> properties, where as other will only accept a single value.
> 
> And there should be a comment to look at the binding document for the
> specific PHY for what it supports. And you need such a document for
> the lantiq.
> 
> Maybe some of the implementation should be pushed into the phylib.
> phy_probe() already looks for the max-speed property, so it could also
> parse these properties and call a function in the phy_driver
> structure.

I also thought about this, but as far as I know there is no standard
interface for these properties. I think setting the max speed is
standardized by the ieee. Should there be a callback with the
information needed for the PHY driver? I think having the parsing in the
generic code will not make the PHY driver much simpler, but we could
later provide these settings for different places like change the
configuration from user space.

Hauke
