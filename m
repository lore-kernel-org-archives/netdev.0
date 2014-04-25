From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net phy: Check for aneg completion before setting
 state to PHY_RUNNING
Date: Fri, 25 Apr 2014 13:08:45 -0400 (EDT)
Message-ID: <20140425.130845.1535177441530671772.davem@davemloft.net>
References: <53587C7F.2000808@gmail.com>
	<CAGVrzcbrm3KO_=NSJz=KOAcPWvVUMm5kPM7nryJBag6BotKgoQ@mail.gmail.com>
	<CAHPKR9Ltie2shuJqdSKbQcVSKwMt-Q8XTfAJRn6gXxVs5fHRwA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org
To: kumaran.4353@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:45041 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751222AbaDYRIr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Apr 2014 13:08:47 -0400
In-Reply-To: <CAHPKR9Ltie2shuJqdSKbQcVSKwMt-Q8XTfAJRn6gXxVs5fHRwA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Balakumaran Kannan <kumaran.4353@gmail.com>
Date: Fri, 25 Apr 2014 11:23:03 +0530

> Here I have a doubt.
>  * Linux network initialization and phy_state_machine runs in separate threads.
>  * And driver doesn't bother about state of phydev.
> Is it correct?
> Doesn't driver need to confirm phydev is ready(PHY_RUNNING) before
> returning to kernel?

The one comment I will make about things here is that the phylib layer
really should not call netif_carrier_on() until the PHY really is
confirmed to be in a state where it will successfully pass traffic.

If it is doing so before auto-negotiation completes and succeeds,
that would be a bug.
