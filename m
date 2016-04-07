From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Thu, 7 Apr 2016 14:28:47 -0500
Message-ID: <5706B4EF.2050600@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46859 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932567AbcDGT2v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Apr 2016 15:28:51 -0400
In-Reply-To: <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob Herring wrote:

>>>> >>>+- reg : Offset and length of the register regions for the device
>>>> >>>+- reg-names : Register region names referenced in 'reg' above.
>>>> >>>+       Required register resource entries are:
>>>> >>>+       "base"   : EMAC controller base register block.
>>>> >>>+       "csr"    : EMAC wrapper register block.
>>>> >>>+       Optional register resource entries are:
>>>> >>>+       "ptp"    : EMAC PTP (1588) register block.
>>>> >>>+                  Required if 'qcom,emac-tstamp-en' is present.
>>>> >>>+       "sgmii"  : EMAC SGMII PHY register block.
>>>> >>>+- interrupts : Interrupt numbers used by this controller
>>>> >>>+- interrupt-names : Interrupt resource names referenced in 'interrupts'
>>>> >>>above.
>>>> >>>+       Required interrupt resource entries are:
>>>> >>>+       "emac_core0"   : EMAC core0 interrupt.
>>>> >>>+       "sgmii_irq"   : EMAC SGMII interrupt.
>>>> >>>+- qcom,emac-gpio-mdc  : GPIO pin number of the MDC line of MDIO bus.
>>>> >>>+- qcom,emac-gpio-mdio : GPIO pin number of the MDIO line of MDIO bus.
>>> >>
>>> >>
>>> >>Use the standard binding for GPIO controlled MDIO bus.
>> >
>> >
>> >I'm not familiar with that one.  Are you talking about
>> >bindings/net/mdio-gpio.txt?

> Yes.
>
>
>>>> >>>+- phy-addr            : Specifies phy address on MDIO bus.
>>>> >>>+                       Required if the optional property
>>>> >>>"qcom,no-external-phy"
>>>> >>>+                       is not specified.
>>> >>
>>> >>
>>> >>Don't you think you will need to know the specific phy device or other
>>> >>properties of the phy?
>> >
>> >
>> >That, I can't answer.  Aren't all MDIO devices basically the same?  It's
>> >been a while since I've worked on them.

> No. There was some discussion just this week about needing to require
> phy devices to have compatible strings.

I'm back to working on this driver, and I need some more help with how 
to handle the phy.  mdio-gpio.txt doesn't really tell me much. I'm 
actually working on an ACPI system and not DT.  I don't want to strip 
out the DT code, but I can't really test it.  I want to keep changes to 
Gilad's patch to a minimum.

Part of the problem with the Emac (and Gilad tried to explain this) is 
that it has an internal phy.  Technically, you can connect this internal 
phy directly to another internal phy on another SOC, and use this as an 
SOC interconnect.  However, I don't know of anyone actually doing that.

Instead, most systems have the internal phy connect to an external phy. 
  This connection is how the Emac receives packets from the external phy.

So I don't understand how I'm supposed to use the binding in 
mdio-gpio.txt.  For one thing, there is no such binding on ACPI systems. 
  On my ACPI system, firmware has set up the GPIOs.  The driver never 
actually makes any gpio_xxx calls.  At this point, I'm tempted to just 
remove all the GPIO stuff from Gilad's patch, if I can't help enough 
help to figure out how to modify the driver the way you think I should.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
