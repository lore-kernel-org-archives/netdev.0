From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: smsc911x: Reset PHY during initialization
Date: Sun, 01 Nov 2015 16:51:51 -0500 (EST)
Message-ID: <20151101.165151.1119828043753664843.davem@davemloft.net>
References: <1446188779-4184-1-git-send-email-p.fedin@samsung.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	steve.glendinning@shawell.net
To: p.fedin@samsung.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:55368 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752741AbbKAVvx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 16:51:53 -0500
In-Reply-To: <1446188779-4184-1-git-send-email-p.fedin@samsung.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Pavel Fedin <p.fedin@samsung.com>
Date: Fri, 30 Oct 2015 10:06:19 +0300

> On certain hardware after software reboot the chip may get stuck and fail
> to reinitialize during reset. This can be fixed by ensuring that PHY is
> reset too.
> 
> Old PHY resetting method required operational MDIO interface, therefore
> the chip should have been already set up. In order to be able to function
> during probe, it is changed to use PMT_CTRL register.
> 
> The problem could be observed on SMDK5410 board.
> 
> Signed-off-by: Pavel Fedin <p.fedin@samsung.com>

I'm pretty sure this is going to break the PHY loopback test.

This is such a tricky and fragile area to get right, therefore I
want you to specifically guard any change in how PHY reset is
done with tests against the specific chips that have the problem.

Furthermore, I want you to test whether this has any negative
effects on the PHY loopback test.
