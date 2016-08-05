From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH] [v7] net: emac: emac gigabit ethernet controller driver
Date: Fri, 5 Aug 2016 14:36:02 -0500
Message-ID: <57A4EAA2.3040208@codeaurora.org>
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
	LinoSanfilippo@gmx.de
To: Rob Herring <robh@kernel.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20160804175541.GA2832@rob-hp-laptop>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rob Herring wrote:
> Sounds like 2 different h/w. The compatible property should distinguish
> this.

So I changed it to this:

- compatible : Should be "qcom,fsm9900-emac" or "qcom,qdf2432-emac",
  	depending on the version of the internal PHY.
	"qcom,fsm9900-emac" is for v1, and "qcom,qdf2432-emac"
	is for v2.

(and changed the code to match).

However, now this doesn't work look right any more:

The external phy child node:
- compatible : Should be "qcom,fsm9900-emac-phy".
- reg : The phy address

I was never crazy about this, because the external PHY is whatever 
device it happens to be.

The phy driver uses of_mdiobus_register, which calls 
of_mdiobus_child_is_phy().  Based on my reading of the code, I think I 
should just drop the compatible property altogether.  Because the way it 
is now causes of_mdiobus_child_is_phy() to return false when it parses 
that node.

-- 
Qualcomm Datacenter Technologies, Inc. as an affiliate of Qualcomm
Technologies, Inc.  Qualcomm Technologies, Inc. is a member of the
Code Aurora Forum, a Linux Foundation Collaborative Project.
