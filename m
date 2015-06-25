From: Mugunthan V N <mugunthanvnm@ti.com>
Subject: Re: [net PATCH 1/1] net: phy: fix phy link up when limiting speed
 via device tree
Date: Fri, 26 Jun 2015 00:32:57 +0530
Message-ID: <558C5061.6090509@ti.com>
References: <1435251062-5287-1-git-send-email-mugunthanvnm@ti.com> <CAGVrzcZcs5n7A+VF3uextDgONS_UNLYDianw=NwH62Bx-6ZEyw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:59726 "EHLO comal.ext.ti.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751555AbbFYTDD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2015 15:03:03 -0400
In-Reply-To: <CAGVrzcZcs5n7A+VF3uextDgONS_UNLYDianw=NwH62Bx-6ZEyw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 25 June 2015 11:01 PM, Florian Fainelli wrote:
> 2015-06-25 9:51 GMT-07:00 Mugunthan V N <mugunthanvnm@ti.com>:
>> > When limiting phy link speed using "max-speed" to 100mbps or less on a
>> > giga bit phy, phy never completes auto negotiation and phy state
>> > machine is held in PHY_AN. Fixing this issue by comparing the giga
>> > bit advertise though phydev->supported doesn't have it but phy has
>> > BMSR_ESTATEN set. So that auto negotiation is restarted as old and
>> > new advertise are different and link comes up fine.
> This looks valid, however, I am curious why this part of the code:
> 
>         oldadv = adv;
>         adv &= ~(ADVERTISE_ALL | ADVERTISE_100BASE4 | ADVERTISE_PAUSE_CAP |
>                  ADVERTISE_PAUSE_ASYM);
>         adv |= ethtool_adv_to_mii_adv_t(advertise);
> 
>         if (adv != oldadv) {
>                 err = phy_write(phydev, MII_ADVERTISE, adv);
> 
>                 if (err < 0)
>                         return err;
>                 changed = 1;
>         }
> 
> Is not flagging this as a change already?
> 

This can flag a change when the selected limit is 10mbps, if 100mbps is
selected, at this instant oldadv and adv are same so change is not
flagged here.

Regards
Mugunthan V N
