From: David Miller <davem@davemloft.net>
Subject: Re: [Patch] net: fix incorrect counting in __scm_destroy()
Date: Wed, 04 Nov 2009 04:41:16 -0800 (PST)
Message-ID: <20091104.044116.37320720.davem@davemloft.net>
References: <20091104100717.4785.57149.sendpatchset@localhost.localdomain>
	<4AF15771.8060204@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: amwang@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35617
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755690AbZKDMkv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 07:40:51 -0500
In-Reply-To: <4AF15771.8060204@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 04 Nov 2009 11:29:05 +0100

> Given we kfree(fpl) at the end of loop, we cannot recursively call
> __scm_destroy() on same fpl, it would be a bug anyway ?
> 
> So you probably need something better, like testing fpl->list being
> not re-included in current->scm_work_list before kfree() it

I can't even see what the problem is.

The code is designed such that the ->count only matters for
the top level.

If we recursively fput() and get back here, we'll see that
there is someone higher in the call chain already running
the fput() loop and we'll just list_add_tail().

The inner while() loop will make sure we process such
entries once we get back to the top level and exit the
for() loop.

Amerigo, please show us the problematic code path where the counts go
wrong and this causes problems.

Thanks.
