From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] net: percpu net_device refcount
Date: Thu, 7 Oct 2010 10:30:51 -0700
Message-ID: <20101007103051.63b5177c@nehalam>
References: <1286471555.2912.291.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:34601 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751044Ab0JGRax (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Oct 2010 13:30:53 -0400
In-Reply-To: <1286471555.2912.291.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 07 Oct 2010 19:12:35 +0200
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> We tried very hard to remove all possible dev_hold()/dev_put() pairs in
> network stack, using RCU conversions.
> 
> There is still an unavoidable device refcount change for every dst we
> create/destroy, and this can slow down some workloads (routers or some
> app servers)
> 
> We can switch to a percpu refcount implementation, now dynamic per_cpu
> infrastructure is mature. On a 64 cpus machine, this consumes 256 bytes
> per device.
> 

It makes sense, but what about 256 cores and 1024 Vlans?
That adds up to 4M of memory which is might be noticeable.


-- 
