From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] tg3: Avoid NULL pointer dereference in
 tg3_io_error_detected()
Date: Fri, 30 Sep 2016 01:28:10 -0400 (EDT)
Message-ID: <20160930.012810.1362145682119450497.davem@davemloft.net>
References: <1475166248-8665-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: siva.kallam@broadcom.com, prashant@broadcom.com,
        mchan@broadcom.com, netdev@vger.kernel.org, miltonm@us.ibm.com
To: gpiccoli@linux.vnet.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:36596 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932836AbcI3F2Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 30 Sep 2016 01:28:16 -0400
In-Reply-To: <1475166248-8665-1-git-send-email-gpiccoli@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Guilherme G. Piccoli" <gpiccoli@linux.vnet.ibm.com>
Date: Thu, 29 Sep 2016 13:24:08 -0300

> From: Milton Miller <miltonm@us.ibm.com>
> 
> While the driver is probing the adapter, an error may occur before the
> netdev structure is allocated and attached to pci_dev. In this case,
> not only netdev isn't available, but the tg3 private structure is also
> not available as it is just math from the NULL pointer, so dereferences
> must be skipped.
> 
> The following trace is seen when the error is triggered:
 ...
> This patch avoids the NULL pointer dereference by moving the access after
> the netdev NULL pointer check on tg3_io_error_detected(). Also, we add a
> check for netdev being NULL on tg3_io_resume() [suggested by Michael Chan].
> 
> Fixes: 0486a063b1ff ("tg3: prevent ifup/ifdown during PCI error recovery")
> Fixes: dfc8f370316b ("net/tg3: Release IRQs on permanent error")
> Tested-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> Signed-off-by: Milton Miller <miltonm@us.ibm.com>
> Signed-off-by: Guilherme G. Piccoli <gpiccoli@linux.vnet.ibm.com>
> ---
> 
>   * v2 changelog: added netdev NULL check on tg3_io_resume() as per
>     Michael Chan's suggestion.

Applied and queued up for -stable, thanks!
