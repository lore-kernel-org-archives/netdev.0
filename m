From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v1] net: phy: fix auto-negotiation stall due to
 unavailable interrupt
Date: Tue, 25 Apr 2017 10:36:44 -0400 (EDT)
Message-ID: <20170425.103644.75674234677063517.davem@davemloft.net>
References: <1492686004-30527-1-git-send-email-al.kochet@gmail.com>
        <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org, sergei.shtylyov@cogentembedded.com,
        rogerq@ti.com, madalin.bucur@nxp.com
To: al.kochet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39512 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948028AbdDYOgq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:36:46 -0400
In-Reply-To: <1492686004-30527-2-git-send-email-al.kochet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Kochetkov <al.kochet@gmail.com>
Date: Thu, 20 Apr 2017 14:00:04 +0300

> The Ethernet link on an interrupt driven PHY was not coming up if the Ethernet
> cable was plugged before the Ethernet interface was brought up.
> 
> The patch trigger PHY state machine to update link state if PHY was requested to
> do auto-negotiation and auto-negotiation complete flag already set.
> 
> During power-up cycle the PHY do auto-negotiation, generate interrupt and set
> auto-negotiation complete flag. Interrupt is handled by PHY state machine but
> doesn't update link state because PHY is in PHY_READY state. After some time
> MAC bring up, start and request PHY to do auto-negotiation. If there are no new
> settings to advertise genphy_config_aneg() doesn't start PHY auto-negotiation.
> PHY continue to stay in auto-negotiation complete state and doesn't fire
> interrupt. At the same time PHY state machine expect that PHY started
> auto-negotiation and is waiting for interrupt from PHY and it won't get it.
> 
> Signed-off-by: Alexander Kochetkov <al.kochet@gmail.com>
> Cc: stable <stable@vger.kernel.org> # v4.9+

So... what are we doing here?

My understanding is that this should fix the same problem that commit
99f81afc139c6edd14d77a91ee91685a414a1c66 ("phy: micrel: Disable auto
negotiation on startup") fixed and that this micrel commit should thus
be reverted to improve MAC startup times which regressed.

Florian, any guidance?
