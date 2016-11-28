From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] net: dsa: fix unbalanced dsa_switch_tree reference
 counting
Date: Mon, 28 Nov 2016 16:16:23 -0500 (EST)
Message-ID: <20161128.161623.368993152050525938.davem@davemloft.net>
References: <1480315728-23398-1-git-send-email-nikita.yoush@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, cphealy@gmail.com, andrew@lunn.ch,
        linux-kernel@vger.kernel.org
To: nikita.yoush@cogentembedded.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42480 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753164AbcK1VQZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 16:16:25 -0500
In-Reply-To: <1480315728-23398-1-git-send-email-nikita.yoush@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
Date: Mon, 28 Nov 2016 09:48:48 +0300

> _dsa_register_switch() gets a dsa_switch_tree object either via
> dsa_get_dst() or via dsa_add_dst(). Former path does not increase kref
> in returned object (resulting into caller not owning a reference),
> while later path does create a new object (resulting into caller owning
> a reference).
> 
> The rest of _dsa_register_switch() assumes that it owns a reference, and
> calls dsa_put_dst().
> 
> This causes a memory breakage if first switch in the tree initialized
> successfully, but second failed to initialize. In particular, freed
> dsa_swith_tree object is left referenced by switch that was initialized,
> and later access to sysfs attributes of that switch cause OOPS.
> 
> To fix, need to add kref_get() call to dsa_get_dst().
> 
> Signed-off-by: Nikita Yushchenko <nikita.yoush@cogentembedded.com>
> Fixes: 83c0afaec7b7 ("net: dsa: Add new binding implementation")
> Reviewed-by: Andrew Lunn <andrew@lunn.ch>

Applied and queued up for -stable, thanks.
