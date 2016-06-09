From: Vincent Palatin <vpalatin@chromium.org>
Subject: Re: [PATCH] net: stmmac: dwmac-rk: keep PHY up for WoL
Date: Thu, 9 Jun 2016 16:00:10 -0700
Message-ID: <CAP_ceTxad-7iaBDPbLShHv04uA-DWsVuGpbLc3=7gX2b060sYw@mail.gmail.com>
References: <1464974960-26672-1-git-send-email-vpalatin@chromium.org>
 <f543c3e1-fa55-a6fd-c916-cf043e562ec2@st.com> <CAP_ceTwLg-e_gUaYLrUiBy8Fu31n=UemzbA_sDP2_-5wiY2p5A@mail.gmail.com>
 <20160609001739.GA2227@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
	Alexandre Torgue <alexandre.torgue@st.com>,
	=?UTF-8?Q?Heiko_St=C3=BCbner?= <heiko@sntech.de>,
	Douglas Anderson <dianders@chromium.org>
To: Andrew Lunn <andrew@lunn.ch>,
	Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f53.google.com ([209.85.214.53]:35144 "EHLO
	mail-it0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750995AbcFIXAb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Jun 2016 19:00:31 -0400
Received: by mail-it0-f53.google.com with SMTP id z189so167329987itg.0
        for <netdev@vger.kernel.org>; Thu, 09 Jun 2016 16:00:31 -0700 (PDT)
In-Reply-To: <20160609001739.GA2227@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 8, 2016 at 5:17 PM, Andrew Lunn <andrew@lunn.ch> wrote:
> On Wed, Jun 08, 2016 at 03:25:38PM -0700, Vincent Palatin wrote:
>> On Tue, Jun 7, 2016 at 12:23 AM, Giuseppe CAVALLARO
>> <peppe.cavallaro@st.com> wrote:
>> > Hello
>> >
>> > On 6/3/2016 7:29 PM, Vincent Palatin wrote:
>> >>
>> >> Do not shutdown the PHY if Wake-on-Lan is enabled, else it cannot wake
>> >> us up.
>> >>
>> >
>> > I do not understand why you need that.
>> > This is done inside the PHY layer and it is tested on our platforms
>> > he idea is: If the parent wants to Wake the system then the PHY should
>> > not power-down.
>>
>> I'm not sure I understand :
>> you mean that this path is not called if WoL is enabled ?
>> [ currently stmmac_pltfr_suspend() is calling priv->plat->exit() which
>> is the rk_gmac_exit() code I'm modifying ]
>> or the RK driver code should not power down the phy in its exit() callback ?
>
> Take a look at phy_suspend().

phy_suspend() sends (or not) the PowerDown command to the PHY through
the MDIO bus,  depending if WoL is disabled,
but most of my question still stands as far as I can tell :
I was trying to get a proper WoL support on the following setup :
  dwmac  (inside a RK3288 SoC) connected to RTL8211 PHY
The current upstream code for this case will call rk_gmac_exit() when
the MAC suspends (after the PHY has already suspended). Effectively
doing a phy_power_on(, false) which is calling regulator_disable() on
the LDO defined by the 'phy-supply' attribute.
So my reading is that the RK specific MAC code is turning off
unconditionally the PHY power regulator. Unless I'm mistaken, either
this code is incorrect for the WoL case or the naming 'phy-supply' is
misleading and should be the MAC supply.

-- 
Vincent
