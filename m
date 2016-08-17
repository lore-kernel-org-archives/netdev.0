From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 14:25:00 -0500
Message-ID: <57B4BA0C.2080602@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
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
	"Abdulhamid, Harb" <harba@codeaurora.org>
To: Al Stone <al.stone@linaro.org>, Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <57B3878D.1000805@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Timur Tabi wrote:
>
> The question, how should adpt->phy.version be initialized on device tree
> and ACPI platforms?
>
> The reason why this is confusing is because there are conflicting
> perspectives of this "internal PHY".  It both is and is not part of the
> EMAC.  It is a separate block in the chip, and can be replaced with
> other SGMII blocks, and in the future there will be a "v3" and maybe a
> "v4" or who knows what.  In fact, maybe using version numbers is
> inappropriate and we'll need to use vendor names or something.
>
> The problem is that the internal PHY has mechanism for
> self-identification.  There is no ACPI or device tree node for it. There
> is no register you can query to see if it's there or what version it
> is.  The MAC part of the EMAC has no knowledge of the PHY part.  The
> driver just has to know it's there.
>
> This is why I'm advocating a separate property (DT and ACPI) to identify
> the internal PHY.

So we had some internal discussion on this.  Different compatible 
properties for DT are okay, and for ACPI we'll either create a 
"phy-version" property (DT-like properties are called DSDs in ACPI) or 
use an HRV (a specific property for the hardware version).

But this speaks to the greater problem of mapping DT compatible strings 
to ACPI.  Like I said, the ACPI equivalent of a compatible string is the 
HID.  But unlike DT, we cannot create new HIDs whenever we feel like it. 
  The process for generating and assigning HIDs is much more involved, 
and we do have a very limited namespace.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
