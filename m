From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH RFT 1/2] phylib: add device reset GPIO support
Date: Sat, 14 May 2016 22:36:38 +0300
Message-ID: <cc232c9e-ef25-482d-0978-cbdfe03bad22@cogentembedded.com>
References: <81129033.NXiOLTg1so@wasted.cogentembedded.com>
 <3641492.klKRrvS8tr@wasted.cogentembedded.com>
 <20160512184233.GJ30822@pengutronix.de> <5735995B.8030802@ti.com>
 <b9bcc192-f97b-304e-77b2-894c4528ddb6@cogentembedded.com>
 <20160513204436.GC7600@lunn.ch>
 <1a44a737-2b81-625b-8edf-d1c3dfcdd619@cogentembedded.com>
 <20160513234410.GE7600@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Roger Quadros <rogerq@ti.com>,
	=?UTF-8?Q?Uwe_Kleine-K=c3=b6nig?= <u.kleine-koenig@pengutronix.de>,
	grant.likely@linaro.org, robh+dt@kernel.org,
	devicetree@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org, frowand.list@gmail.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-kernel@vger.kernel.org,
	Linus Walleij <linus.walleij@linaro.org>
To: Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160513234410.GE7600@lunn.ch>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 05/14/2016 02:44 AM, Andrew Lunn wrote:

>>>>> Another issue is that on some boards we have one reset line tied to
>>>>> multiple PHYs.How do we prevent multiple resets being taking place when each of
>>>>> the PHYs are registered?
>>>>
>>>>   My patch just doesn't address this case -- it's about the
>>>> individual resets only.
>>>
>>> This actually needs to be addresses a layer above. What you have is a
>>> bus reset, not a device reset.
>>
>>    No.
>>    There's simply no such thing as a bus reset for the xMII/MDIO
>> busses, there's simply no reset signaling on them. Every device has
>> its own reset signal and its own timing requirements.
>
> Except in the case above, where two phys are sharing the same reset
> signal. So although it is not part of the mdio standard to have a bus
> reset, this is in effect what the gpio line is doing, resetting all
> devices on the bus. If you don't model that as a bus reset, how do you
> model it?

    I'm not suggesting that the shared reset should be handled by my patch. 
Contrariwise, I suggested to use the mii_bus::reset() method -- I see it as a 
necessary evil. However, in the more common case of a single PHY, this method 
simply doesn't scale -- you'd have to teach each and every individual MAC/ 
MDIO driver to do the GPIO reset trick.

>       Andrew

MBR, Sergei
