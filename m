From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net v2] l2tp: fix use-after-free during module unload
Date: Fri, 02 Sep 2016 11:45:10 -0700 (PDT)
Message-ID: <20160902.114510.2079683210993243165.davem@davemloft.net>
References: <996e12b7faf7fd20ba9c0c76614fd5bb4a3d70c4.1472804437.git.sd@queasysnail.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sergei.shtylyov@cogentembedded.com
To: sd@queasysnail.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55322 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752847AbcIBSpL (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2016 14:45:11 -0400
In-Reply-To: <996e12b7faf7fd20ba9c0c76614fd5bb4a3d70c4.1472804437.git.sd@queasysnail.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sabrina Dubroca <sd@queasysnail.net>
Date: Fri,  2 Sep 2016 10:22:54 +0200

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
> from l2tp_exit_net() by first flushing the tunnel removal workqueue, and
> then waiting for RCU callbacks to complete.
> 
> Fixes: 167eb17e0b17 ("l2tp: create tunnel sockets in the right namespace")
> Signed-off-by: Sabrina Dubroca <sd@queasysnail.net>
> ---
> v2: fix typo in commit message, spotted by Sergei Shtylyov

Applied.
