From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Mon, 15 Aug 2016 15:06:24 -0500
Message-ID: <57B220C0.3060608@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org,
	linux-arm-msm@vger.kernel.org, sdharia@codeaurora.org,
	shankerd@codeaurora.org, vikrams@codeaurora.org,
	cov@codeaurora.org, gavidov@codeaurora.org, andrew@lunn.ch,
	bjorn.andersson@linaro.org, mlangsdo@redhat.com, jcm@redhat.com,
	agross@codeaurora.org, davem@davemloft.net, f.fainelli@gmail.com,
	LinoSanfilippo@gmx.de, "Rafael J. Wysocki" <rjw@rjwysocki.net>,
	Al Stone <al.stone@linaro.org>
To: Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:46371 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753032AbcHOUG1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Aug 2016 16:06:27 -0400
In-Reply-To: <20160804175541.GA2832@rob-hp-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

+ Rafael and Al, for ACPI help.

Rob Herring wrote:
>> >+Optional properties:
>> >+- phy-version : the version of the integrated emac phy, either 1 or 2.

> Sounds like 2 different h/w. The compatible property should distinguish
> this.

So I implemented this in v8 of my driver, but it is causing problems for 
ACPI.

In ACPI, the equivalent to a compatible string is the HID, which is 
QCOM8070 for the EMAC.  The problem is that it's very difficult, if not 
impossible, to create new HIDs for different versions of the same device.

The driver will primarily (if not exclusively) be used on ACPI 
platforms, not DT.  In Qualcomm, DT is for mobile chips, and ACPI is for 
server.  To my knowledge, there are no plans to use this driver on an 
actual DT-enabled platform, but I want to support DT anyway.

The other problem is that the "internal PHY" of the EMAC is technically 
a separate device, and it's interchangeable.  Future versions of our 
chips will use different internal PHYs, but the EMAC will stay the same.

So I would like a solution that works on DT and ACPI.  I suppose I could 
use compatible strings on DT, and a "phy-version" DSD (property) on 
ACPI.  If that's acceptable to everyone, then I can do that.  It seems 
clunky to me.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
