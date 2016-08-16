From: Al Stone <al.stone@linaro.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 16 Aug 2016 15:20:09 -0600
Message-ID: <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
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
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Timur Tabi <timur@codeaurora.org>, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57B31780.5030106@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 08/16/2016 07:39 AM, Timur Tabi wrote:
> Rob Herring wrote:
> 
>>> In ACPI, the equivalent to a compatible string is the HID, which is QCOM8070
>>> for the EMAC.  The problem is that it's very difficult, if not impossible,
>>> to create new HIDs for different versions of the same device.
>>
>> Different versions are different devices IMO.
> 
> Not that I disagree, but this appears to be an inherent problem with ACPI.  The
> namespace for ACPI HIDs is very limited.  We only really have control over the
> last two digits.

My apologies if the stuff below is things you already know...I never know how
much people already know about ACPI, and sometimes just don't know when to shut
up :).

An _HID is a three or four character company ID followed by four digits that
the company decides on.  The only thing the ASWG (ACPI Spec Working Group)
controls are those first characters; you can do whatever you'd like with the
four digits that follow.

Not knowing enough about the products in mind here, or future plans for them,
I'd recommend taking a look at section 6.1 of the spec.  There's an ACPI object
called _HRV (Hardware Revision) that may do what you need; there is also the
_CID (Compatible ID), or if this is a PCI device, perhaps the _CLS (Class Code)
can be used.  I guess what I'm really trying to say is that the "name space"
mentioned here [*] is not that limited and has quite a bit of flexibility.


[*] "ACPI namespace" has a fairly specific meaning that is different.

>>> The other problem is that the "internal PHY" of the EMAC is technically a
>>> separate device, and it's interchangeable.  Future versions of our chips
>>> will use different internal PHYs, but the EMAC will stay the same.
>>
>> How do you know? EMAC could just as easily change. It's Gigabit today,
>> 10G tomorrow.
> 
> My point is that the EMAC part won't change for the foreseeable future, but I
> know the internal PHY component will change.  The new "version" of the EMAC/PHY
> combo on a future chip will have the same ACPI HID.  So I need some other way to
> differentiate the two.  I can't query the hardware, because the EMAC half will
> be identical.
> 
>> But if it is separate, then maybe you should model it as a separate
>> device using the phy binding.
> 
> It's only separate in hardware.  The driver controls both parts as a unified whole.
> 
>>> So I would like a solution that works on DT and ACPI.  I suppose I could use
>>> compatible strings on DT, and a "phy-version" DSD (property) on ACPI.  If
>>> that's acceptable to everyone, then I can do that.  It seems clunky to me.
>>
>> On one hand, why should I care about ACPI for defining DT bindings?
>> OTOH, having a phy-version property alone would not be a big deal, but
>> you still need distinct compatible strings regardless.
> 
> So you're saying that it's okay to have separate compatible strings AND a
> phy-version property?  That would solve the problem.
> 

Does the ACPI portion of the driver *have* to know about the PHY?  In general,
the ACPI assumption on ARM [**] is that those have all been set up before we
get to the kernel.  So, does it need to be visible to the ACPI part of the
driver at all?


[**] See Documentation/arm64/arm-acpi.txt.

-- 
ciao,
al
-----------------------------------
Al Stone
Software Engineer
Linaro Enterprise Group
al.stone@linaro.org
-----------------------------------
