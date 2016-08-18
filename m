From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Wed, 17 Aug 2016 22:27:19 -0500
Message-ID: <57B52B17.1080809@codeaurora.org>
References: <1470255143-3979-1-git-send-email-timur@codeaurora.org>
 <20160804175541.GA2832@rob-hp-laptop> <57B220C0.3060608@codeaurora.org>
 <CAL_JsqL5xk3mH=h-m8nU8xTYbRjgMWt3p7BzYWj6vBUq4OpqMg@mail.gmail.com>
 <57B31780.5030106@codeaurora.org>
 <f3a49762-aa66-1949-bd6b-77bd6a74acc1@linaro.org>
 <57B3878D.1000805@codeaurora.org>
 <ff901f77-2177-52a7-2464-2f61495f91be@gmail.com>
 <57B4C6EE.3080903@codeaurora.org> <57B4E5F7.9040500@codeaurora.org>
 <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com>
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
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <bec781c6-2db9-02c7-687d-b5d6ee50c129@gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Florian Fainelli wrote:

>>      emac_sgmii: ethernet-phy@410400 {
>>          compatible = "qcom,qdf2432-emac-phy";
>>          reg = <0x0 0x00410400 0x0 0x100>;
>>          interrupts = <0 0x104 0>;
>>      };
>>
>
> Is this register range relative to the emac0 node here, or is this
> really a separate node, within the same adress space as your emac0 node?

It's a separate node within the same address space.  We can't guarantee 
that it's adjacent to any other EMAC register -- it could be anywhere in 
memory. 0x00410400 is the real physical address of those registers.

> Answer largely depends on whether your device is really located outside
> of the emac, if it located outside, then a platform device matching the
> compatible string would get you what you want. If the emac_sgmii block
> is a sub-block within the EMAC, then a few things need fixing:
>
> - your emac_sgmii node should be a sub-node of the emac node, not a sibling
> - the emac0 node should have a "ranges" property that indicates how to
> translate the sub-nodes' "reg" property based on the base register
> address of the emac0 block
> - you would have to call of_platform_populate from the EMAC driver to
> ensure that the emac_sgmii child node and therefore platform device gets
> created

Even if the emac_sgmii block were a sub-block, wouldn't it conflict with 
the ethernet-phy@4 node?  The #address-cells and #size-cells properties 
cannot be valid for both the emac_sgmii and ethernet-phy@4 nodes.

-- 
Sent by an employee of the Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the
Code Aurora Forum, hosted by The Linux Foundation.
