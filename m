From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] l2tp: fix race condition in l2tp_tunnel_delete
Date: Thu, 21 Sep 2017 11:53:02 -0700 (PDT)
Message-ID: <20170921.115302.675934534188865164.davem@davemloft.net>
References: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, g.nault@alphalink.fr, lucien.xin@gmail.com,
        tparkin@katalix.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:52624 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750790AbdIUSxD (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 21 Sep 2017 14:53:03 -0400
In-Reply-To: <6bfc5aceda47773af4c75fe7e0e3c0d255a2342d.1505828155.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 19 Sep 2017 15:40:40 +0200

> If we try to delete the same tunnel twice, the first delete operation
> does a lookup (l2tp_tunnel_get), finds the tunnel, calls
> l2tp_tunnel_delete, which queues it for deletion by
> l2tp_tunnel_del_work.
> 
> The second delete operation also finds the tunnel and calls
> l2tp_tunnel_delete. If the workqueue has already fired and started
> running l2tp_tunnel_del_work, then l2tp_tunnel_delete will queue the
> same tunnel a second time, and try to free the socket again.
> 
> Add a dead flag to prevent firing the workqueue twice. Then we can
> remove the check of queue_work's result that was meant to prevent that
> race but doesn't.
> 
> Also check the flag in the tunnel lookup functions, to avoid returning a
> tunnel that is already scheduled for destruction.

Sabrina, please respond to Guillaume's feedback.

Thank you.
