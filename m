From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] l2tp: fix use-after-free during module unload
Date: Thu, 01 Sep 2016 16:34:16 -0700 (PDT)
Message-ID: <20160901.163416.76744449780953103.davem@davemloft.net>
References: <f30d3c9f96a7de81af18061ac61a2d24ef179bf8.1472557704.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:40660 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752151AbcIAXeR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2016 19:34:17 -0400
In-Reply-To: <f30d3c9f96a7de81af18061ac61a2d24ef179bf8.1472557704.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Tue, 30 Aug 2016 16:05:16 +0200

> Tunnel deletion is delayed by both a workqueue (l2tp_tunnel_delete -> wq
>  -> l2tp_tunnel_del_work) and RCU (sk_destruct -> RCU ->
> l2tp_tunnel_destruct).
> 
> By the time l2tp_tunnel_destruct() runs to destroy the tunnel and finish
> destroying the socket, the private data reserved via the net_generic
> mechanism has already been freed, but l2tp_tunnel_destruct() actually
> uses this data.
> 
> Make sure tunnel deletion for the netns has completed before returning
> from l2tp_net_exit() by first flushing the tunnel removal workqueue, and
> then waiting for RCU callbacks to complete.
> 
> Fixes: 167eb17e0b17 ("l2tp: create tunnel sockets in the right namespace")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>

Please resubmit this with Sergei's feedback addressed.

Thanks.
