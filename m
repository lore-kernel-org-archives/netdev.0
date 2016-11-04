From: Mason <slash.tmp@free.fr>
Subject: Re: Ethernet not working on a different SoC with same eth HW
Date: Fri, 4 Nov 2016 14:51:47 +0100
Message-ID: <581C9273.906@free.fr>
References: <58176355.7090200@free.fr> <20161031153704.GD9441@lunn.ch>
 <581767BF.4020308@free.fr> <20161031155334.GF9441@lunn.ch>
 <58177128.8090403@free.fr> <581C8691.2060306@free.fr>
 <yw1xy40zjrcw.fsf@unicorn.mansr.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: netdev <netdev@vger.kernel.org>, Andrew Lunn <andrew@lunn.ch>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Timur Tabi <timur@codeaurora.org>,
        Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
        Zefir Kurtisi <zefir.kurtisi@neratec.com>,
        Martin Blumenstingl <martin.blumenstingl@gmail.com>,
        Uwe Kleine-Konig <u.kleine-koenig@pengutronix.de>,
        Daniel Mack <zonque@gmail.com>,
        Sebastian Frias <sf84@laposte.net>
To: Mans Rullgard <mans@mansr.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:62561 "EHLO smtp5-g21.free.fr"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1755107AbcKDNwN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Fri, 4 Nov 2016 09:52:13 -0400
In-Reply-To: <yw1xy40zjrcw.fsf@unicorn.mansr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/11/2016 14:40, Måns Rullgård wrote:

> Mason <slash.tmp@free.fr> writes:
> 
>> On 31/10/2016 17:28, Mason wrote:
>>
>>> On 31/10/2016 16:53, Andrew Lunn wrote:
>>>
>>>>> I'll add a log for the request_irq call.
>>>>
>>>> And take a look at /proc/interrupts
>>>
>>> You're right, there does seem to be something wrong with the interrupts.
>>
>> Having fixed that, I'm still unable to ping a box on the same
>> ethernet segment... Still investigating.
>>
>> I think I may have spotted a potential issue in the Atheros driver.
>>
>> 	if (phydev->interface == PHY_INTERFACE_MODE_RGMII_RXID ||
>> 	    phydev->interface == PHY_INTERFACE_MODE_RGMII_ID) {
>> 		ret = at803x_enable_rx_delay(phydev);
>> 		if (ret < 0)
>> 			return ret;
>> 	}
>>
>> Looking at this code, one might believe that "rgmii rx clock delay"
>> is only enabled when the user requests it (through DT).
>>
>> http://www.redeszone.net/app/uploads/2014/04/AR8035.pdf
>> cf. PDF page 48
>>
>> *However* this bit is set to 1 at reset (both HW and SW resets).
>> Thus, "rgmii rx clock delay" is always enabled, whether the user
>> requests it or not.
>>
>> Could someone knowledgeable comment on the expected behavior of
>> enabling rgmii rx (and tx) clock delay?
> 
> Clock delay is sometimes (depending on PCB layout) required to achieve
> the correct timing between clock and data signals.  The delay can be
> applied at the MAC or the PHY.  I'd start by finding out what the PCB
> design expects or check the signals with a fast oscilloscope if you have
> one.

Considering the ethernet DT bindings:

https://www.kernel.org/doc/Documentation/devicetree/bindings/net/ethernet.txt

Specifically, phy-mode values "rgmii", "rgmii-id", "rgmii-rxid", "rgmii-txid".

Assuming that "rxid" (rx internal delay) and "rx clock delay" are
in fact the same concept with different names, do you agree that
it would be unexpected for "rgmii rx clock delay" to be enabled
when a DTB specifies "rgmii" or "rgmii-txid" ?

Regards.
