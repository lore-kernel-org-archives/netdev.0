From: Vikram Sethi <vikrams@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 08 Apr 2016 16:07:34 -0500
Message-ID: <57081D96.902@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org> <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org> <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com> <5706B4EF.2050600@codeaurora.org> <20160407201009.GA16136@lunn.ch> <5706D493.8020700@codeaurora.org> <20160408005317.GA28125@lunn.ch> <5708013F.90207@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh@kernel.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Christopher Covington <cov@codeaurora.org>
To: Timur Tabi <timur@codeaurora.org>, Andrew Lunn <andrew@lunn.ch>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <5708013F.90207@codeaurora.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/08/2016 02:06 PM, Timur Tabi wrote:
> Andrew Lunn wrote:
>
>> There are two different things here. One is configuring the pin to be
>> a GPIO. The second is using the GPIO as a GPIO. In this case,
>> bit-banging the MDIO bus.
>>
>> The firmware could be doing the configuration, setting the pin as a
>> GPIO. However, the firmware cannot be doing the MDIO bit-banging to
>> make an MDIO bus available. Linux has to do that.
>>
>> Or it could be we have all completely misunderstood the hardware, and
>> we are not doing bit-banging GPIO MDIO. There is a real MDIO
>> controller there, we don't use these pins as GPIOs, etc....
>
> Actually, I think there is a misunderstanding.
>
> On the FSM9900 SOC (which uses device-tree), the two pins that connect to the external PHY are gpio pins.  However, the driver needs to reprogram the pinmux so that those pins are wired to the Emac controller.  That's what the the gpio code in this driver is doing: it's just configuring the pins so that they connect directly between the Emac and the external PHY.  After that, they are no longer GPIO pins, and you cannot use the "GPIO controlled MDIO bus".  There is no MDIO controller on the SOC.  The external PHY is controlled directly from the Emac and also from the internal PHY.  It is screwy, I know, but that's what Gilad was trying to explain.
It is incorrect to say there's no MDIO controller on the SoC. The EMAC Core on the SoC itself has a MDIO controller which talks to the external PHY. The internal SGMII is not on MDIO however.
Please see the EMAC specification.
>
> On the QDF2432 (which uses ACPI), those two wires are now dedicated. There are not muxed GPIOs any more -- they are hard wired between Emac and the external PHY.
>
> In both cases, you need to use Emac registers to communicate with the external PHY.  Stuff like link detect and link speed are configured by programming the Emac and/or the internal phy.
You need to use EMAC *MDIO* registers to communicate with external PHY.
>
> And the internal phy isn't really an internal phy.  It's an SGMII-like device that's connected to the Emac and handles various phy-related tasks.  It has its own register block, but you still have to program it in concert with the Emac.  You can't really treat it separately.
>
> So I'm beginning to believe that Gilad's driver is actually correct as-is.  There are a few minor bug fixes, but in general it's correct.  I would like to post a V4 soon that has those minor fixes.
>


-- 
Vikram Sethi
Qualcomm Technologies Inc, on behalf of Qualcomm Innovation Center, Inc.
Qualcomm Innovation Center, Inc. is a member of Code Aurora Forum, a Linux Foundation Collaborative Project
