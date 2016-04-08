From: Timur Tabi <timur@codeaurora.org>
Subject: Re: [PATCH V3] net: emac: emac gigabit ethernet controller driver
Date: Fri, 8 Apr 2016 18:01:08 -0500
Message-ID: <57083834.2060102@codeaurora.org>
References: <1451440135-25771-1-git-send-email-gavidov@codeaurora.org>
 <20151231231039.GA8886@rob-hp-laptop> <56ABADEA.40801@codeaurora.org>
 <CAL_JsqLnJt+mdL==-qP-EJhMa2rA6i-AyDESj69wNVt7D5JJUQ@mail.gmail.com>
 <5706B4EF.2050600@codeaurora.org> <20160407201009.GA16136@lunn.ch>
 <5706D493.8020700@codeaurora.org> <20160408005317.GA28125@lunn.ch>
 <5708013F.90207@codeaurora.org>
 <CAOCOHw5R=PnkafRqx2eGKKm10eLgD4H3u7TjbbhdZMbqVR7LrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Lunn <andrew@lunn.ch>, Rob Herring <robh@kernel.org>,
	Gilad Avidov <gavidov@codeaurora.org>,
	netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	linux-arm-msm <linux-arm-msm@vger.kernel.org>,
	Sagar Dharia <sdharia@codeaurora.org>, shankerd@codeaurora.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	vikrams@codeaurora.org, Christopher Covington <cov@codeaurora.org>
To: Bjorn Andersson <bjorn.andersson@linaro.org>
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <CAOCOHw5R=PnkafRqx2eGKKm10eLgD4H3u7TjbbhdZMbqVR7LrA@mail.gmail.com>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Bjorn Andersson wrote:

> It sounds like you're trying to say that the pins used can be are
> muxed as GPIO or MDIO, in the TLMM.

I'm not 100% sure, but I think that's correct.  If you don't want to 
have normal networking, you could connect those external pins to some 
GPIO device (like an LED or whatever), and then configure the pin muxing 
for GPIO purposes.  But if that's true, it's only true on the FSM9900. 
On the QDF2432, those lines are not connected to the TLMM.  They are 
instead hard-wired to the Emac.

> In the downstream kernel this is often seen with the drivers calling
> gpio_request() to "reserve" said pins, but all you should do is
> described the desired configuration and muxing in the pinctrl node,
> reference that from your driver and simply ignore the fact that those
> pins could have been used as GPIO pins.

That makes sense, but I think the driver already does that.

https://patchwork.ozlabs.org/patch/561667/

Function emac_probe_resources() has a call to of_get_named_gpio().  And 
then emac_mac_up() calls gpio_request().  As far as I can tell, that's it.

I'm guessing that the of_get_named_gpio() call needs to be changed 
somehow, but I'm not sure how.

-- 
Qualcomm Innovation Center, Inc.
The Qualcomm Innovation Center, Inc. is a member of the Code Aurora
Forum, a Linux Foundation collaborative project.
