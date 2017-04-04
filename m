From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: take reference on sessions being dumped
Date: Tue, 04 Apr 2017 10:02:52 -0700 (PDT)
Message-ID: <20170404.100252.646823807636951948.davem@davemloft.net>
References: <806d0d7d9411be40c4910a1fa2e5ea438f3d0e1d.1491213045.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jchapman@katalix.com
To: g.nault@alphalink.fr
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:60498 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752570AbdDDRDG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 13:03:06 -0400
In-Reply-To: <806d0d7d9411be40c4910a1fa2e5ea438f3d0e1d.1491213045.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Guillaume Nault <g.nault@alphalink.fr>
Date: Mon, 3 Apr 2017 12:03:13 +0200

> Take a reference on the sessions returned by l2tp_session_find_nth()
> (and rename it l2tp_session_get_nth() to reflect this change), so that
> caller is assured that the session isn't going to disappear while
> processing it.
> 
> For procfs and debugfs handlers, the session is held in the .start()
> callback and dropped in .show(). Given that pppol2tp_seq_session_show()
> dereferences the associated PPPoL2TP socket and that
> l2tp_dfs_seq_session_show() might call pppol2tp_show(), we also need to
> call the session's .ref() callback to prevent the socket from going
> away from under us.
> 
> Fixes: fd558d186df2 ("l2tp: Split pppol2tp patch into separate l2tp and ppp parts")
> Fixes: 0ad6614048cf ("l2tp: Add debugfs files for dumping l2tp debug info")
> Fixes: 309795f4bec2 ("l2tp: Add netlink control API for L2TP")
> Signed-off-by: Guillaume Nault <g.nault@alphalink.fr>

Applied and queued up for -stable, thanks.
