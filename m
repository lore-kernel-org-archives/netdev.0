From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 15:19:58 -0500
Message-ID: <57B4C6EE.3080903@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
 <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
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
	Lino Sanfilippo <LinoSanfilippo@gmx.de>,
	"Rafael J. Wysocki" <rjw@rjwysocki.net>,
	"Abdulhamid, Harb" <harba@codeaurora.org>
To: Florian Fainelli <f.fainelli@gmail.com>,
	Al Stone <al.stone@linaro.org>, Rob Herring <robh@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:59105 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752829AbcHQUUC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 16:20:02 -0400
In-Reply-To: <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Florian Fainelli wrote:

> If it has self identification, and the MAC is capable of knowing what
> kind of PHY it is internally bundled with, why does it matter to
> represent that specific piece of information in Device Tree or ACPI?

That's the thing - the MAC is not capable of knowing.  From a hardware 
perspective, the MAC and PHY are physically distinct IP blocks, and so 
the MAC hardware has no idea what it's really connected to.  In theory, 
we don't even need an internal PHY, but if there is an internal PHY, we 
have to program it correctly.

This is why we need a DT and ACPI property (or whatever) to tell the 
driver what kind of PHY it's attached to.

>> The problem is that the internal PHY has mechanism for
>> self-identification.  There is no ACPI or device tree node for it. There
>> is no register you can query to see if it's there or what version it
>> is.  The MAC part of the EMAC has no knowledge of the PHY part.  The
>> driver just has to know it's there.
>
> Nothing prevents you from detailing in ACPI or DT sub-components of a
> larger HW block, if there is such a desire, but just make it in a way
> that it looks like what would be done for e.g: separate discrete parts,
> only the parenting of nodes would change.

So instead of just having a single property, instead create a child node 
just for the SGMII phy, with its own compatible string and various other 
properties (like interrupt and base register)?  That's not a bad idea.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
