From: Nathan Rossi <nathan@nathanrossi.com>
Subject: Re: [PATCH] net: macb: Add support for phy-handle binding
Date: Thu, 18 Feb 2016 04:44:35 +1000
Message-ID: <CA+aJhH13H87z4=SBvZaOjND3RZRDSyxBp1ctYD5ssHKHg5eToQ@mail.gmail.com>
References: <1455379368-18739-1-git-send-email-nathan@nathanrossi.com>
	<20160217.121414.529895298809970981.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	nicolas.ferre@atmel.com
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160217.121414.529895298809970981.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 18, 2016 at 3:14 AM, David Miller <davem@davemloft.net> wrote:
> From: Nathan Rossi <nathan@nathanrossi.com>
> Date: Sun, 14 Feb 2016 02:02:48 +1000
>
>> This patch adds support for the 'phy-handle' binding which allows for a
>> system to specifically select a phy which can be attached via any MDIO
>> bus available in the system.
>>
>> Signed-off-by: Nathan Rossi <nathan@nathanrossi.com>
>> Cc: Nicolas Ferre <nicolas.ferre@atmel.com>
>
> I don't see how this can be backwards compatible at all.
>
> In my opinion we are way too loose about handling things like this.
>
> Existing chips that happened to have an OF node but lack a phy-handle
> property are going to be broken by that change.
>
> I know you are now going to bombard me with all kinds of reasons why
> this won't happen.
>
> Don't bother, I'm simply not interested.

The intention with this patch is to maintain existing dt bindings
alongside being able to use phy-handle, but I am not completely
familiar with all the use cases of the macb driver so I can't know for
sure if this change does not break certain cases. So I fully
understand your point.

>
> All of these special cases we use (all the DT bindings are in text
> files in the kernel sources, we control all of the bootloaders, etc.)
> is the most shaky foundation I've ever seen upon which to erect a
> stable device probing mechanism.
>
> I'm not applying this patch until you add an error handling path from
> the of_phy_connect() call that will do the existing PHY probing sequence
> by hand using phy_find_first().

I am not quite sure how to handle that in a way such as to also allow
for the probe deferral in the event that the phydev/mdio bus which the
phy-handle points at is not yet probed itself. But I guess the real
question is whether or not to handle the deferral at all?

Thanks,
Nathan
