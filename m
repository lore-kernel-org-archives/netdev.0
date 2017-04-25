From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] ipvlan: use pernet operations and restrict
 l3s hooks to master netns
Date: Tue, 25 Apr 2017 10:43:49 -0400 (EDT)
Message-ID: <20170425.104349.2185336124073374885.davem@davemloft.net>
References: <20170420160815.7201-1-fw@strlen.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, maheshb@google.com
To: fw@strlen.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39776 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1948189AbdDYOnx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2017 10:43:53 -0400
In-Reply-To: <20170420160815.7201-1-fw@strlen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>
Date: Thu, 20 Apr 2017 18:08:15 +0200

> commit 4fbae7d83c98c30efc ("ipvlan: Introduce l3s mode") added
> registration of netfilter hooks via nf_register_hooks().
> 
> This API provides the illusion of 'global' netfilter hooks by placing the
> hooks in all current and future network namespaces.
> 
> In case of ipvlan the hook appears to be only needed in the namespace
> that contains the ipvlan master device (i.e., usually init_net), so
> placing them in all namespaces is not needed.
> 
> This switches ipvlan driver to pernet operations, and then only registers
> hooks in namespaces where a ipvlan master device is set to l3s mode.
> 
> Extra care has to be taken when the master device is moved to another
> namespace, as we might have to 'move' the netfilter hooks too.
> 
> This is done by storing the namespace the ipvlan port was created in.
> On REGISTER event, do (un)register operations in the old/new namespaces.
> 
> This will also allow removal of the nf_register_hooks() in a future patch.
> 
> Cc: Mahesh Bandewar <maheshb@google.com>
> Signed-off-by: Florian Westphal <fw@strlen.de>

Applied, thanks Florian.
