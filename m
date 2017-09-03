From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] l2tp: session creation fixes
Date: Sun, 03 Sep 2017 11:04:36 -0700 (PDT)
Message-ID: <20170903.110436.325862367776935727.davem@davemloft.net>
References: <cover.1504277892.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:56498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753099AbdICSEh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 3 Sep 2017 14:04:37 -0400
In-Reply-To: <cover.1504277892.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 1 Sep 2017 17:58:45 +0200

> The session creation process has a few issues wrt. concurrent tunnel
> deletion.
> 
> Patch #1 avoids creating sessions in tunnels that are getting removed.
> This prevents races where sessions could try to take tunnel resources
> that were already released.
> 
> Patch #2 removes some racy l2tp_tunnel_find() calls in session creation
> callbacks. Together with path #1 it ensures that sessions can only
> access tunnel resources that are guaranteed to remain valid during the
> session creation process.
> 
> 
> There are other problems with how sessions are created: pseudo-wire
> specific data are set after the session is added to the tunnel. So
> the session can be used, or deleted, before it has been completely
> initialised. Separating session allocation from session registration
> would be necessary, but we'd still have circular dependencies
> preventing race-free registration. I'll consider this issue in future
> series.

Series applied, thanks.
