From: David Miller <davem@davemloft.net>
Subject: Re: sky2: fix cleanup sequence in probe() function
Date: Mon, 03 Dec 2012 13:53:04 -0500 (EST)
Message-ID: <20121203.135304.402769242967325322.davem@davemloft.net>
References: <20121201123928.GA3914@neptun>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, mlindner@marvell.com, netdev@vger.kernel.org
To: LinoSanfilippo@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:39401 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab2LCSxG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Dec 2012 13:53:06 -0500
In-Reply-To: <20121201123928.GA3914@neptun>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lino Sanfilippo <LinoSanfilippo@gmx.de>
Date: Sat, 1 Dec 2012 13:39:28 +0100

> The cleanup sequence in sky2_probe() that is called in case of an error is
> mixed up in different places:
> 
> - pci_disable_device() is not called in each case the device has been enabled
> before
> 
> - same for pci_disable_msi(): test_msi() may return with an error != EOPNOTSUPP
> (due to failure of request_irq()). In that case msi is not disabled
> 
> - also failure of register_netdev() does not disable msi
> 
> This patch fixes the concerning parts.
> 
> Signed-off-by: Lino Sanfilippo <LinoSanfilippo@gmx.de>

This looks clearly correct to me, so I've applied it to net-next, thanks.
