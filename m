From: Timur Tabi <timur-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 8 Apr 2016 16:45:31 -0500
Message-ID: <5708267B.8050503@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
 <5706B4EF.2050600@codeaurora.org> <20160407201009.GA16136@lunn.ch>
 <5706D493.8020700@codeaurora.org> <20160408005317.GA28125@lunn.ch>
 <5708013F.90207@codeaurora.org> <57081D96.902@codeaurora.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Rob Herring <robh-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Gilad Avidov <gavidov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	linux-arm-msm <linux-arm-msm-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Sagar Dharia <sdharia-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, shankerd-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org,
	Greg Kroah-Hartman <gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org>,
	Christopher Covington <cov-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
To: Vikram Sethi <vikrams-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>, Andrew Lunn <andrew-g2DYL2Zd6BY@public.gmane.org>
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <57081D96.902-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Vikram Sethi wrote:

>> On the FSM9900 SOC (which uses device-tree), the two pins that connect to the external PHY are gpio pins.  However, the driver needs to reprogram the pinmux so that those pins are wired to the Emac controller.  That's what the the gpio code in this driver is doing: it's just configuring the pins so that they connect directly between the Emac and the external PHY.  After that, they are no longer GPIO pins, and you cannot use the "GPIO controlled MDIO bus".  There is no MDIO controller on the SOC.  The external PHY is controlled directly from the Emac and also from the internal PHY.  It is screwy, I know, but that's what Gilad was trying to explain.
> It is incorrect to say there's no MDIO controller on the SoC. The EMAC Core on the SoC itself has a MDIO controller which talks to the external PHY. The internal SGMII is not on MDIO however.
> Please see the EMAC specification.

Sorry, I should have said that there is no *independent* MDIO controller 
(one that has its own driver).  As you said, you can only talk to the 
external PHY through the Emac.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
