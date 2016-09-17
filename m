From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xen-netback: fix error handling on netback_probe()
Date: Sat, 17 Sep 2016 09:56:31 -0400 (EDT)
Message-ID: <20160917.095631.1210055450319054136.davem@davemloft.net>
References: <1473952246-27037-1-git-send-email-filipe.manco@neclab.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wei.liu2@citrix.com,
        xen-devel@lists.xenproject.org
To: filipe.manco@neclab.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60032 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751544AbcIQN4e (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 17 Sep 2016 09:56:34 -0400
In-Reply-To: <1473952246-27037-1-git-send-email-filipe.manco@neclab.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Filipe Manco <filipe.manco@neclab.eu>
Date: Thu, 15 Sep 2016 17:10:46 +0200

> In case of error during netback_probe() (e.g. an entry missing on the
> xenstore) netback_remove() is called on the new device, which will set
> the device backend state to XenbusStateClosed by calling
> set_backend_state(). However, the backend state wasn't initialized by
> netback_probe() at this point, which will cause and invalid transaction
> and set_backend_state() to BUG().
> 
> Initialize the backend state at the beginning of netback_probe() to
> XenbusStateInitialising, and create two new valid state transitions on
> set_backend_state(), from XenbusStateInitialising to XenbusStateClosed,
> and from XenbusStateInitialising to XenbusStateInitWait.
> 
> Signed-off-by: Filipe Manco <filipe.manco@neclab.eu>

Applied, thanks.
