From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: phy: adjust fixed_phy_register() return
 value
Date: Sat, 04 Oct 2014 20:02:49 -0400 (EDT)
Message-ID: <20141004.200249.1455277042095588643.davem@davemloft.net>
References: <20141001214509.2BF4F10070D@puck.mtv.corp.google.com>
	<20141004140731.15c18a77@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: pgynther@google.com, netdev@vger.kernel.org, f.fainelli@gmail.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43931 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751033AbaJEACx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 4 Oct 2014 20:02:53 -0400
In-Reply-To: <20141004140731.15c18a77@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Sat, 4 Oct 2014 14:07:31 +0200

> I am not sure this return (!phy || IS_ERR(phy)) is doing the right
> thing. This function is supposed to return an error code on failure, or
> 0 on success. I don't see how your error handling returns an error code
> on failure. What about doing the more explicit:
> 
> 		phy = fixed_phy_register(PHY_POLL, &status, np);
> 		if (IS_ERR(phy))
> 			return PTR_ERR(phy);
> 		else
> 			return 0;
> 
> Or am I missing something?

Agreed, there is no circumstance under which the new fixed_phy_register()
should return a NULL pointer.
