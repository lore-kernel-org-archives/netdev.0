From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: emac: Fix napi poll list corruption
Date: Tue, 19 Sep 2017 16:20:54 -0700 (PDT)
Message-ID: <20170919.162054.1346334879894995770.davem@davemloft.net>
References: <20170919173518.3694-1-chunkeey@googlemail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chunkeey@googlemail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50654 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751634AbdISXUy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2017 19:20:54 -0400
In-Reply-To: <20170919173518.3694-1-chunkeey@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Christian Lamparter <chunkeey@googlemail.com>
Date: Tue, 19 Sep 2017 19:35:18 +0200

> This patch is pretty much a carbon copy of
> commit 3079c652141f ("caif: Fix napi poll list corruption")
> with "caif" replaced by "emac".
> 
> The commit d75b1ade567f ("net: less interrupt masking in NAPI")
> breaks emac.
> 
> It is now required that if the entire budget is consumed when poll
> returns, the napi poll_list must remain empty.  However, like some
> other drivers emac tries to do a last-ditch check and if there is
> more work it will call napi_reschedule and then immediately process
> some of this new work.  Should the entire budget be consumed while
> processing such new work then we will violate the new caller
> contract.
> 
> This patch fixes this by not touching any work when we reschedule
> in emac.
> 
> Signed-off-by: Christian Lamparter <chunkeey@googlemail.com>

Applied and queued up for -stable, thanks.
