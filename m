From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/5] l2tp: fix usage of l2tp_session_find()
Date: Sat, 01 Apr 2017 20:17:07 -0700 (PDT)
Message-ID: <20170401.201707.1914746615264022070.davem@davemloft.net>
References: <cover.1490955471.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com, bhong@brocade.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60240 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdDBDRJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 1 Apr 2017 23:17:09 -0400
In-Reply-To: <cover.1490955471.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Fri, 31 Mar 2017 13:02:23 +0200

> l2tp_session_find() doesn't take a reference on the session returned to
> its caller. Virtually all l2tp_session_find() users are racy, either
> because the session can disappear from under them or because they take
> a reference too late. This leads to bugs like 'use after free' or
> failure to notice duplicate session creations.
> 
> In some cases, taking a reference on the session is not enough. The
> special callbacks .ref() and .deref() also have to be called in cases
> where the PPP pseudo-wire uses the socket associated with the session.
> Therefore, when looking up a session, we also have to pass a flag
> indicating if the .ref() callback has to be called.
> 
> In the future, we probably could drop the .ref() and .deref() callbacks
> entirely by protecting the .sock field of struct pppol2tp_session with
> RCU, thus allowing it to be freed and set to NULL even if the L2TP
> session is still alive.

Series applied with the Fixes: tag of patch #5 updated.

Thanks.
