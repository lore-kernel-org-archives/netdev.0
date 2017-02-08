From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] ipv6: addrconf: fix generation of new temporary
 addresses
Date: Wed, 08 Feb 2017 11:55:19 -0500 (EST)
Message-ID: <20170208.115519.683941247979533576.davem@davemloft.net>
References: <20170206173455.ghiltporvklvumsp@linux.fritz.box>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
        kaber@trash.net, netdev@vger.kernel.org
To: suse-tux@gmx.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:54122 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752009AbdBHQze (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 11:55:34 -0500
In-Reply-To: <20170206173455.ghiltporvklvumsp@linux.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Marcus Huewe <suse-tux@gmx.de>
Date: Mon, 6 Feb 2017 18:34:56 +0100

> Under some circumstances it is possible that no new temporary addresses
> will be generated.
> 
> For instance, addrconf_prefix_rcv_add_addr() indirectly calls
> ipv6_create_tempaddr(), which creates a tentative temporary address and
> starts dad. Next, addrconf_prefix_rcv_add_addr() indirectly calls
> addrconf_verify_rtnl(). Now, assume that the previously created temporary
> address has the least preferred lifetime among all existing addresses and
> is still tentative (that is, dad is still running). Hence, the next run of
> addrconf_verify_rtnl() is performed when the preferred lifetime of the
> temporary address ends. If dad succeeds before the next run, the temporary
> address becomes deprecated during the next run, but no new temporary
> address is generated.
> 
> In order to fix this, schedule the next addrconf_verify_rtnl() run slightly
> before the temporary address becomes deprecated, if dad succeeded.
> 
> Signed-off-by: Marcus Huewe <suse-tux@gmx.de>

Applied, thank you.
