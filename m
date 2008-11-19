From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] phylib: Fix auto-negotiation restart avoidance
Date: Wed, 19 Nov 2008 15:52:17 -0800 (PST)
Message-ID: <20081119.155217.234975526.davem@davemloft.net>
References: <1226957605-5407-1-git-send-email-tpiepho@freescale.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, scottwood@freescale.com,
	afleming@freescale.com
To: tpiepho@freescale.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:42017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752401AbYKSXwR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Nov 2008 18:52:17 -0500
In-Reply-To: <1226957605-5407-1-git-send-email-tpiepho@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Trent Piepho <tpiepho@freescale.com>
Date: Mon, 17 Nov 2008 13:33:25 -0800

> A previous patch, 51e2a3846eab18711f4eb59cd0a4c33054e2980a, made
> genphy_config_aneg() not restart aneg by calling genphy_restart_aneg() if
> the advertisement hadn't changed.
> 
> But, genphy_restart_aneg() doesn't just restart aneg, it may also *enable*
> aneg or un-isolate the PHY from the MII (those functions are controlled by
> the same register).  The code to avoid calling genphy_restart_aneg() didn't
> consider this.
> 
> So, modify genphy_config_aneg() to also check if the PHY needs to have aneg
> enabled or be un-isolated before deciding not to restart aneg.
> 
> This caused a problem with certain Davicom PHYs, as that driver isolates
> the PHY (why?) before calling genphy_config_aneg() and expects the PHY to
> be un-isolated by that function.
> 
> Signed-off-by: Trent Piepho <tpiepho@freescale.com>
> Reported-by: Scott Wood <scottwood@freescale.com>
> CC: Andy Fleming <afleming@freescale.com>
> ---
> This fixes a 2.6.28 regression.

I'll apply this, thanks a lot.
