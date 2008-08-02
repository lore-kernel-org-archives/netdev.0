From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] NULL pointer dereference in skb_dequeue
Date: Fri, 01 Aug 2008 18:03:37 -0700 (PDT)
Message-ID: <20080801.180337.233358413.davem@davemloft.net>
References: <9929d2390808011640o58453023s623faa8930064505@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, emil.s.tantilov@intel.com
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58331
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751805AbYHBBDi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Aug 2008 21:03:38 -0400
In-Reply-To: <9929d2390808011640o58453023s623faa8930064505@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Jeff Kirsher" <jeffrey.t.kirsher@intel.com>
Date: Fri, 1 Aug 2008 16:40:04 -0700

> BUG: unable to handle kernel NULL pointer dereference at 0000000000000008
> IP: [<ffffffff8047b8f3>] __skb_dequeue+0x2d/0x35
> PGD 0
> Oops: 0002 [1] SMP
> CPU 2
> Modules linked in: igb nfsd lockd exportfs sunrpc pci_slot inet_lro
> [last unloaded: igb]
> Pid: 13, comm: events/2 Not tainted 2.6.27-rc1-igb #1
> RIP: 0010:[<ffffffff8047b8f3>]  [<ffffffff8047b8f3>] __skb_dequeue+0x2d/0x35
 ...
>  [<ffffffff8047bad4>] ? pfifo_fast_reset+0x1f/0x4c

Looks like two threads are accessing the qdisc SKB lists but one of
them isn't taking the proper qdisc locks.

I can't see how this can happen currently but I'll try to figure it
out.
