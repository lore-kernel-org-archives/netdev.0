From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net] xen-netback: make sure that hashes are not send
 to unaware frontends
Date: Fri, 07 Oct 2016 23:53:15 -0400 (EDT)
Message-ID: <20161007.235315.1445609703306777270.davem@davemloft.net>
References: <1475829151-3707-1-git-send-email-paul.durrant@citrix.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, xen-devl@lists.xenproject.org,
        wei.liu2@citrix.com
To: paul.durrant@citrix.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:59960 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757434AbcJHDxT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 7 Oct 2016 23:53:19 -0400
In-Reply-To: <1475829151-3707-1-git-send-email-paul.durrant@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Durrant <paul.durrant@citrix.com>
Date: Fri, 7 Oct 2016 09:32:31 +0100

> In the case when a frontend only negotiates a single queue with xen-
> netback it is possible for a skbuff with a s/w hash to result in a
> hash extra_info segment being sent to the frontend even when no hash
> algorithm has been configured. (The ndo_select_queue() entry point makes
> sure the hash is not set if no algorithm is configured, but this entry
> point is not called when there is only a single queue). This can result
> in a frontend that is unable to handle extra_info segments being given
> such a segment, causing it to crash.
> 
> This patch fixes the problem by clearing the hash in ndo_start_xmit()
> instead, which is clearly guaranteed to be called irrespective of the
> number of queues.
> 
> Signed-off-by: Paul Durrant <paul.durrant@citrix.com>

Applied, thanks.
