From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Mon, 4 Mar 2013 04:55:27 +0100
Message-ID: <20130304035527.GF3401@two.firstfloor.org>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
 <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
 <1362335704.15793.81.camel@edumazet-glaptop>
 <20130303192153.GC3401@two.firstfloor.org>
 <1362345601.15793.83.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andi Kleen <andi@firstfloor.org>,
	Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from two.firstfloor.org ([193.170.194.197]:35118 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757109Ab3CDDz3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 3 Mar 2013 22:55:29 -0500
Content-Disposition: inline
In-Reply-To: <1362345601.15793.83.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 03, 2013 at 01:20:01PM -0800, Eric Dumazet wrote:
> On Sun, 2013-03-03 at 20:21 +0100, Andi Kleen wrote:
> > > Alternative to 2) would be to use a generation id, incremented every
> > > time a napi used in spin polling enabled driver is dismantled (and freed
> > > after RCU grace period)
> > > 
> > > And store in sockets not only the pointer to napi_struct, but the
> > > current generation id : If the generation id doesnt match, disable
> > > the spinpoll until next packet rebuilds the cache again.
> > 
> > This would require rcu_read_lock, aka preempt off, during polling, right?
> > 
> 
> Of course, polling probably needs BH disabling as well to get the per
> napi lock

Ok maybe the cond_resched() is good enough.

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
