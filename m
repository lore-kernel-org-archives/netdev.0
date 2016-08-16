From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Tue, 16 Aug 2016 16:37:17 -0500
Message-ID: <57B3878D.1000805@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
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
	"Rafael J. Wysocki" <rjw@rjwysocki.net>
To: Al Stone <al.stone@linaro.org>, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Al Stone wrote:
> Does the ACPI portion of the driver*have*  to know about the PHY?  In general,
> the ACPI assumption on ARM [**] is that those have all been set up before we
> get to the kernel.  So, does it need to be visible to the ACPI part of the
> driver at all?

Yes, the driver supports both "v1" and "v2" of the PHY, and it has code 
like this:

	if (adpt->phy.version == 2)
		emac_sgmii_init_v2(adpt);
	else
		emac_sgmii_init_v1(adpt);

The question, how should adpt->phy.version be initialized on device tree 
and ACPI platforms?

The reason why this is confusing is because there are conflicting 
perspectives of this "internal PHY".  It both is and is not part of the 
EMAC.  It is a separate block in the chip, and can be replaced with 
other SGMII blocks, and in the future there will be a "v3" and maybe a 
"v4" or who knows what.  In fact, maybe using version numbers is 
inappropriate and we'll need to use vendor names or something.

The problem is that the internal PHY has mechanism for 
self-identification.  There is no ACPI or device tree node for it. 
There is no register you can query to see if it's there or what version 
it is.  The MAC part of the EMAC has no knowledge of the PHY part.  The 
driver just has to know it's there.

This is why I'm advocating a separate property (DT and ACPI) to identify 
the internal PHY.

The truth is that I don't really care HOW it's done, and as long as we 
come to a consensus soon.  I want my driver to be merged into 4.9.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
