From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: hold tunnel in pppol2tp_connect()
Date: Tue, 31 Oct 2017 11:04:26 +0900 (KST)
Message-ID: <20171031.110426.452915902112397213.davem@davemloft.net>
References: <684fcf4b6a907b378274b92f033f7b78b2021809.1509381647.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:50664 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdJaCEc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 30 Oct 2017 22:04:32 -0400
In-Reply-To: <684fcf4b6a907b378274b92f033f7b78b2021809.1509381647.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 30 Oct 2017 17:58:58 +0100

> Use l2tp_tunnel_get() in pppol2tp_connect() to ensure the tunnel isn't
> going to disappear while processing the rest of the function.
> 
> Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>
> ---
> 
> Note: in case of backporting to -stable, this patch only makes sense if
> f3c66d4e144a ("l2tp: prevent creation of sessions on terminated tunnels")
> is already present in the tree, as we need this issue to be fixed
> before fixing the current one.
> 
> The reason is that when connecting a session, we don't only depend on
> the tunnel, but also on its socket. Therefore, holding a reference on
> the tunnel is not enough, we also have to make sure that it's not going
> to drop its socket before the session is registered.

Applied and thank you for the detailed -stable explanation, it really
helps.
