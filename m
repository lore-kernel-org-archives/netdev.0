From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCH] Add support for running the Marvell m88e1111 PHY in RGMII mode
Date: Wed, 11 Apr 2007 03:01:58 +0200
Message-ID: <20070411010158.GB9526@xi.wantstofly.org>
References: <20070410165723.472fdc69.kim.phillips@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Jeff Garzik <jgarzik@pobox.com>
To: Kim Phillips <kim.phillips@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from alephnull.demon.nl ([83.160.184.112]:52791 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161133AbXDKBCB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Apr 2007 21:02:01 -0400
Content-Disposition: inline
In-Reply-To: <20070410165723.472fdc69.kim.phillips@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Apr 10, 2007 at 04:57:23PM -0500, Kim Phillips wrote:

> also adds RX & TX delay bits to help boards with clock skew problems.

This doesn't make sense at all.

RGMII specifies that clock and data are generated simultaneously.  The
necessary 1.5-2ns of clock delay is either achieved by routing the RGMII
clock net to have that amount of skew, or by programming the RGMII
receiver to add that amount of clock delay internally.

So, boards that have 'clock skew problems' should have RX & TX delay
turned OFF.  Boards that route the clock nets without any skew should
have RX & TX delay turned on.

Your patch unconditionally enables clock delay in the 88e1111, which
only makes sense if the RGMII data and clock nets are routed to have
the approximate same amount of delay.  Which means that it is entirely
board-specific whether this should be enabled or not.  If you enable
the 88e1111 internal RX/TX clock delay feature on a board that also
routes the RGMII clock nets to have the appropriate amount of skew,
things are likely to break entirely.


> [...]
> +
> +		temp |= (MII_M1111_RX_DELAY | MII_M1111_TX_DELAY);

Enabling this unconditionally is just wrong.

I.e. the patch is wrong, and the description is wrong too.
