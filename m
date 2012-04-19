From: Jonas Gorski <jonas.gorski@gmail.com>
Subject: Re: [PATCH] NET: bcm63xx_enet: move phy_(dis)connect into probe/remove
Date: Thu, 19 Apr 2012 16:52:46 +0200
Message-ID: <CAOiHx==f0czkaEVTe=+wabQMmifdaN00PMQwaR8f-602Dq56pA@mail.gmail.com>
References: <1334750537-14896-1-git-send-email-jonas.gorski@gmail.com>
 <1334753296.5185.3.camel@sakura.staff.proxad.net> <CAOiHx=khEqKaAsD++=0BXEzutaWCgi-30B=6hYyLChfkAaHXXA@mail.gmail.com>
 <1334842380.5185.29.camel@sakura.staff.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev@vger.kernel.org, Florian Fainelli <florian@openwrt.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"David S. Miller" <davem@davemloft.net>
To: mbizon@freebox.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:65009 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752558Ab2DSOxI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Apr 2012 10:53:08 -0400
Received: by ghrr11 with SMTP id r11so4467832ghr.19
        for <netdev@vger.kernel.org>; Thu, 19 Apr 2012 07:53:07 -0700 (PDT)
In-Reply-To: <1334842380.5185.29.camel@sakura.staff.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 19 April 2012 15:33, Maxime Bizon <mbizon@freebox.fr> wrote:
>
> On Wed, 2012-04-18 at 21:30 +0200, Jonas Gorski wrote:
>>
>> The phy state machine will start in PHY_READY after phy_connect, which
>> will result in NOPs, so no call to bcm_enet_adjust_phy_link() after
>> _probe() and before _open(). The state machine starts doing real work
>> only after calling phy_start(), which happens only after the dma
>> register accesses in open(). So no race here.
>
> If I read the phylib code correctly, after phy_connect() the phy is in
> READY state, and you can access it via ethtool.

Yes, but none of the ethtool functions cause register writes in the
priv->has_phy = true case when in PHY_READY or PHY_HALTED state. All
they do is modify the phy_device's settings.
The settings only get taken over when the phy is started and the
phy_state_machine is running, so after phy_start() was and before
phy_stop().

In the priv->has_phy = false case they do cause register writes since
bcm_enet_adjust_link() might get called, but these never use the phy
state machine, so my patch does not change anything there.


Jonas
