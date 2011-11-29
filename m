From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] icplus: mdio_write(), remove unnecessary for loop
Date: Tue, 29 Nov 2011 18:47:58 -0500 (EST)
Message-ID: <20111129.184758.1166451793914536662.davem@davemloft.net>
References: <1322149145-32242-1-git-send-email-patrick.kelle81@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, romieu@fr.zoreil.com, sorbica@icplus.com.tw
To: patrick.kelle81@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:44652 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756571Ab1K2XtP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 18:49:15 -0500
In-Reply-To: <1322149145-32242-1-git-send-email-patrick.kelle81@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Patrick Kelle <patrick.kelle81@gmail.com>
Date: Thu, 24 Nov 2011 16:39:05 +0100

> At this point the variable j is always set to 7 and the code within
> the loop has to run only once anyway.
> 
> Signed-off-by: Patrick Kelle <patrick.kelle81@gmail.com>

You can simply this even further since p[7] is what is used here,
and this means len is one, the inner loop therefore executes only
once, and the p[7].field value is not used (it's zero in the table)
and the write to it is completely thrown away.

It all reduces to something like:

	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_LO | polarity);
	ipg_r8(PHY_CTRL);
	ipg_write_phy_ctl(ioaddr, IPG_PC_MGMTCLK_HI | polarity);

Which is just asserting the management clock low, then high, and
doing a PHY_CTRL read in between to force the write out, the read
data is not used at all.
