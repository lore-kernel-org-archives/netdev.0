From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 16 Aug 2016 08:39:12 -0500
Message-ID: <57B31780.5030106@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
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
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:41820 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932172AbcHPNjS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 09:39:18 -0400
In-Reply-To: <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Rob Herring wrote:

>> In ACPI, the equivalent to a compatible string is the HID, which is QCOM8070
>> for the EMAC.  The problem is that it's very difficult, if not impossible,
>> to create new HIDs for different versions of the same device.
>
> Different versions are different devices IMO.

Not that I disagree, but this appears to be an inherent problem with 
ACPI.  The namespace for ACPI HIDs is very limited.  We only really have 
control over the last two digits.

>> The other problem is that the "internal PHY" of the EMAC is technically a
>> separate device, and it's interchangeable.  Future versions of our chips
>> will use different internal PHYs, but the EMAC will stay the same.
>
> How do you know? EMAC could just as easily change. It's Gigabit today,
> 10G tomorrow.

My point is that the EMAC part won't change for the foreseeable future, 
but I know the internal PHY component will change.  The new "version" of 
the EMAC/PHY combo on a future chip will have the same ACPI HID.  So I 
need some other way to differentiate the two.  I can't query the 
hardware, because the EMAC half will be identical.

> But if it is separate, then maybe you should model it as a separate
> device using the phy binding.

It's only separate in hardware.  The driver controls both parts as a 
unified whole.

>> So I would like a solution that works on DT and ACPI.  I suppose I could use
>> compatible strings on DT, and a "phy-version" DSD (property) on ACPI.  If
>> that's acceptable to everyone, then I can do that.  It seems clunky to me.
>
> On one hand, why should I care about ACPI for defining DT bindings?
> OTOH, having a phy-version property alone would not be a big deal, but
> you still need distinct compatible strings regardless.

So you're saying that it's okay to have separate compatible strings AND 
a phy-version property?  That would solve the problem.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
