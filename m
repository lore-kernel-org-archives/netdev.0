From: Ben Dooks <ben.dooks@codethink.co.uk>
Subject: Re: [PATCH] phy: micrel: add of configuration for LED mode
Date: Thu, 27 Feb 2014 10:30:51 +0000
Message-ID: <530F13DB.90009@codethink.co.uk>
References: <1393415280-10227-1-git-send-email-ben.dooks@codethink.co.uk> <20140227091505.GA6945@e106331-lin.cambridge.arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@lists.codethink.co.uk"
	<linux-kernel@lists.codethink.co.uk>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"f.fainelli@gmail.com" <f.fainelli@gmail.com>
To: Mark Rutland <mark.rutland@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ducie-dc1.codethink.co.uk ([185.25.241.215]:52794 "EHLO
	ducie-dc1.codethink.co.uk" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751858AbaB0Kay (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 05:30:54 -0500
In-Reply-To: <20140227091505.GA6945@e106331-lin.cambridge.arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 27/02/14 09:15, Mark Rutland wrote:
> On Wed, Feb 26, 2014 at 11:48:00AM +0000, Ben Dooks wrote:
>> Add support for the led-mode property for the following PHYs
>> which have a single LED mode configuration value.
>>
>> KSZ8001 and KSZ8041 which both use register 0x1e bits 15,14 and
>> KSZ8021, KSZ8031 and KSZ8051 which use register 0x1f bits 5,4
>> to control the LED configuration.
>>
>> Signed-off-by: Ben Dooks <ben.dooks@codethink.co.uk>
>> ---
>>   Documentation/devicetree/bindings/net/micrel.txt | 18 +++++++++
>>   drivers/net/phy/micrel.c                         | 49 ++++++++++++++++++++++--
>>   2 files changed, 63 insertions(+), 4 deletions(-)
>>   create mode 100644 Documentation/devicetree/bindings/net/micrel.txt
>>
>> diff --git a/Documentation/devicetree/bindings/net/micrel.txt b/Documentation/devicetree/bindings/net/micrel.txt
>> new file mode 100644
>> index 0000000..98a3e61
>> --- /dev/null
>> +++ b/Documentation/devicetree/bindings/net/micrel.txt
>> @@ -0,0 +1,18 @@
>> +Micrel PHY properties.
>> +
>> +These properties cover the base properties Micrel PHYs.
>> +
>> +Optional properties:
>> +
>> + - micrel,led-mode : LED mode value to set for PHYs with configurable LEDs.
>> +
>> +              Configure the LED mode with single value. The list of PHYs and
>> +	      the bits that are currently supported:
>> +
>> +	      KSZ8001: register 0x1e, bits 15..14
>> +	      KSZ8041: register 0x1e, bits 15..14
>> +	      KSZ8021: register 0x1f, bits 5..4
>> +	      KSZ8031: register 0x1f, bits 5..4
>> +	      KSZ8051: register 0x1f, bits 5..4
>> +
>> +              See the respective PHY datasheet for the mode values.
>
> What do these mean, roughly,, and why can the kernel not decide how to
> cnofigure these?

Board specific, in the case of the Lager one of the LEDs is connected
to the ethernet mac block to indicate link, however the default mode
is not for just "Link" so we have to change it.

> In general we prefer to not place raw register values in the DT, and I'd
> like to know why we'd have to here.

I could copy out stuff from the data-sheet, but I was trying to avoid a
copy and paste job.


-- 
Ben Dooks				http://www.codethink.co.uk/
Senior Engineer				Codethink - Providing Genius
