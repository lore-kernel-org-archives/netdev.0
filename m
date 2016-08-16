From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 16 Aug 2016 08:29:51 -0500
Message-ID: <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>,
	Shanker Donthineni <shankerd@codeaurora.org>,
	Vikram Sethi <vikrams@codeaurora.org>,
	Christopher Covington <cov@codeaurora.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	Andrew Lunn <andrew@lunn.ch>,
	Bjorn Andersson <bjorn.andersson@linaro.org>,
	Mark Langsdorf <mlangsdo@redhat.com>,
	"jcm@redhat.com" <jcm@redhat.com>,
	Andy Gross <agross@codeaurora.org>,
	David Miller <davem@davemloft.net>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Al Stone <al.stone@linaro.org>
To: Timur Tabi <timur@codeaurora.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:60126 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753185AbcHPNaR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Aug 2016 09:30:17 -0400
In-Reply-To: <57B220C0.3060608@codeaurora.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 15, 2016 at 3:06 PM, Timur Tabi <timur@codeaurora.org> wrote:
> + Rafael and Al, for ACPI help.
>
> Rob Herring wrote:
>>>
>>> >+Optional properties:
>>> >+- phy-version : the version of the integrated emac phy, either 1 or 2.
>
>
>> Sounds like 2 different h/w. The compatible property should distinguish
>> this.
>
>
> So I implemented this in v8 of my driver, but it is causing problems for
> ACPI.
>
> In ACPI, the equivalent to a compatible string is the HID, which is QCOM8070
> for the EMAC.  The problem is that it's very difficult, if not impossible,
> to create new HIDs for different versions of the same device.

Different versions are different devices IMO.

> The driver will primarily (if not exclusively) be used on ACPI platforms,
> not DT.  In Qualcomm, DT is for mobile chips, and ACPI is for server.  To my
> knowledge, there are no plans to use this driver on an actual DT-enabled
> platform, but I want to support DT anyway.
>
> The other problem is that the "internal PHY" of the EMAC is technically a
> separate device, and it's interchangeable.  Future versions of our chips
> will use different internal PHYs, but the EMAC will stay the same.

How do you know? EMAC could just as easily change. It's Gigabit today,
10G tomorrow.

But if it is separate, then maybe you should model it as a separate
device using the phy binding.

> So I would like a solution that works on DT and ACPI.  I suppose I could use
> compatible strings on DT, and a "phy-version" DSD (property) on ACPI.  If
> that's acceptable to everyone, then I can do that.  It seems clunky to me.

On one hand, why should I care about ACPI for defining DT bindings?
OTOH, having a phy-version property alone would not be a big deal, but
you still need distinct compatible strings regardless.

Rob
