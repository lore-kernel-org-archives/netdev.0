From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net 0/2] net: Fix oops on state free after lwt module
 unload
Date: Fri, 20 Jan 2017 12:03:21 -0500 (EST)
Message-ID: <20170120.120321.688277769193451439.davem@davemloft.net>
References: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tom@herbertland.com,
        roopa@cumulusnetworks.com
To: rshearma@brocade.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:33594 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751391AbdATRD0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2017 12:03:26 -0500
In-Reply-To: <1484753523-26230-1-git-send-email-rshearma@brocade.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Robert Shearman <rshearma@brocade.com>
Date: Wed, 18 Jan 2017 15:32:01 +0000

> This patchset fixes an oops in lwtstate_free and a memory leak that
> would otherwise be exposed by ensuring that references are taken on
> modules that need to stay around to clean up lwt state. To faciliate
> this all ops that implement destroy_state and that can be configured
> to build as a module are changed specify the owner module in the
> ops. The intersection of those two sets is just ila at the moment.

Two things:

1) Under no circumstances should we allow a lwtunnel ops implementing
   module to unload while there is a rule using those ops which is
   alive.

   Therefore, we should not special case the destroy op.  We should
   unconditionally grab the module reference.

2) Please add the new 'owner' field and add an appropriate assignment
   for ops->owner to _every_ lwtunnel implementation, and do so in
   your first patch.  Please do not only do this for ILA.

Thanks.
