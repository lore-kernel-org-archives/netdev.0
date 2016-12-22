From: Al Viro <viro@ZenIV.linux.org.uk>
Subject: Re: [PATCH net 1/1] tipc: revert use of copy_from_iter_full()
Date: Thu, 22 Dec 2016 01:21:01 +0000
Message-ID: <20161222012101.GF1555@ZenIV.linux.org.uk>
References: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org,
        parthasarathy.bhuvaragan@ericsson.com, ying.xue@windriver.com,
        maloy@donjonn.com, tipc-discussion@lists.sourceforge.net
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zeniv.linux.org.uk ([195.92.253.2]:49936 "EHLO
        ZenIV.linux.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753024AbcLVCJk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 21:09:40 -0500
Content-Disposition: inline
In-Reply-To: <1482368497-7103-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 08:01:37PM -0500, Jon Maloy wrote:
> commit cbbd26b8b1a6 ("[iov_iter] new primitives - copy_from_iter_full()
> and friends") replaced calls to copy_from_iter() in the function
> tipc_msg_build(). This causes a an immediate crash as follows:

Very interesting.

> [ 1209.597076] BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> [ 1209.607025] IP: copy_from_iter_full+0x43/0x290

> [ 1209.689257]  tipc_msg_build+0xe1/0x590 [tipc]
> [ 1209.691479]  ? _raw_spin_unlock_bh+0x1e/0x20
> [ 1209.694641]  ? tipc_node_find+0x30/0xa0 [tipc]
> [ 1209.696789]  __tipc_sendmsg+0x189/0x480 [tipc]
> [ 1209.699017]  ? remove_wait_queue+0x4d/0x60
> [ 1209.700354]  tipc_connect+0x15f/0x1b0 [tipc]
> [ 1209.701684]  SYSC_connect+0xd9/0x110

I don't believe that it's something tipc-specific; could you post an objdump
of copy_from_iter_full() in your kernel?  That smells like a bug in there
and it really ought to be fixed...
