From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bgmac: stop clearing DMA receive control register
 right after it is set
Date: Mon, 31 Oct 2016 20:51:37 -0400 (EDT)
Message-ID: <20161031.205137.959277684113173080.davem@davemloft.net>
References: <1477935123-29638-1-git-send-email-gospo@broadcom.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, hauke@hauke-m.de
To: gospo@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:32804 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S948344AbcKAA4u (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 31 Oct 2016 20:56:50 -0400
In-Reply-To: <1477935123-29638-1-git-send-email-gospo@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Andy Gospodarek <gospo@broadcom.com>
Date: Mon, 31 Oct 2016 13:32:03 -0400

> Current bgmac code initializes some DMA settings in the receive control
> register for some hardware and then immediately clears those settings.
> Not clearing those settings results in ~420Mbps *improvement* in
> throughput; this system can now receive frames at line-rate on Broadcom
> 5871x hardware compared to ~520Mbps today.  I also tested a few other
> values but found there to be no discernible difference in CPU
> utilization even if burst size and prefetching values are different.
> 
> On the hardware tested there was no need to keep the code that cleared
> all but bits 16-17, but since there is a wide variety of hardware that
> used this driver (I did not look at all hardware docs for hardware using
> this IP block), I find it wise to move this call up and clear bits just
> after reading the default value from the hardware rather than completely
> removing it.
> 
> This is a good candidate for -stable >=3.14 since that is when the code
> that was supposed to improve performance (but did not) was introduced.
> 
> Signed-off-by: Andy Gospodarek <gospo@broadcom.com>
> Fixes: 56ceecde1f29 ("bgmac: initialize the DMA controller of core...")
> Cc: Hauke Mehrtens <hauke@hauke-m.de>

Applied and queued up for -stable, thanks.
