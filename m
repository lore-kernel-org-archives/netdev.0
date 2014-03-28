From: David Miller <davem@davemloft.net>
Subject: Re: [PATCHv3] net: mvneta: use devm_ioremap_resource() instead of
 of_iomap()
Date: Fri, 28 Mar 2014 16:10:07 -0400 (EDT)
Message-ID: <20140328.161007.1937376826264802047.davem@davemloft.net>
References: <1395916769-20475-1-git-send-email-thomas.petazzoni@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	alior@marvell.com, gregory.clement@free-electrons.com,
	ezequiel.garcia@free-electrons.com
To: thomas.petazzoni@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:40454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752033AbaC1UKK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Mar 2014 16:10:10 -0400
In-Reply-To: <1395916769-20475-1-git-send-email-thomas.petazzoni@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Date: Thu, 27 Mar 2014 11:39:29 +0100

> The mvneta driver currently uses of_iomap(), which has two drawbacks:
> it doesn't request the resource, and it isn't devm-style so some error
> handling is needed.
> 
> This commit switches to use devm_ioremap_resource() instead, which
> automatically requests the resource (so the I/O registers region shows
> up properly in /proc/iomem), and also is devm-style, which allows to
> get rid of some error handling to unmap the I/O registers region.
> 
> Signed-off-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Does this actually fix any bugs?  It seems like the unmaps happen in
all the necessary cases.

If it's just a simplification or cleanup I'm going to apply this to
net-next.
