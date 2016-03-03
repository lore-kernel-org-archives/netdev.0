From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V3] net: ezchip: adapt driver to little endian
 architecture
Date: Thu, 03 Mar 2016 17:20:43 -0500 (EST)
Message-ID: <20160303.172043.676796529681577242.davem@davemloft.net>
References: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Alexey.Brodkin@synopsys.com, noamc@ezchip.com, talz@ezchip.com,
	arnd@arndb.de
To: Lada.Trimasova@synopsys.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:48299 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756850AbcCCWUq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Mar 2016 17:20:46 -0500
In-Reply-To: <1457014066-27651-1-git-send-email-ltrimas@synopsys.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Lada Trimasova <Lada.Trimasova@synopsys.com>
Date: Thu,  3 Mar 2016 17:07:46 +0300

> Since ezchip network driver is written with big endian EZChip platform it
> is necessary to add support for little endian architecture.
> 
> The first issue is that the order of the bits in a bit field is
> implementation specific. So all the bit fields are removed.
> Named constants are used to access necessary fields.
> 
> And the second one is that network byte order is big endian.
> For example, data on ethernet is transmitted with most-significant
> octet (byte) first. So in case of little endian architecture
> it is important to swap data byte order when we read it from
> register. In case of unaligned access we can use "get_unaligned_be32"
> and in other case we can use function "ioread32_rep" which reads all
> data from register and works either with little endian or big endian
> architecture.
> 
> And then when we are going to write data to register we need to restore
> byte order using the function "put_unaligned_be32" in case of
> unaligned access and in other case "iowrite32_rep".
> 
> The last little fix is a space between type and pointer to observe
> coding style.
> 
> Signed-off-by: Lada Trimasova <ltrimas@synopsys.com>

Applied to net-next, thanks.
