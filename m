From: Andi Kleen <andi@firstfloor.org>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Sun, 3 Mar 2013 20:21:53 +0100
Message-ID: <20130303192153.GC3401@two.firstfloor.org>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
 <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
 <1362335704.15793.81.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1362335704.15793.81.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Alternative to 2) would be to use a generation id, incremented every
> time a napi used in spin polling enabled driver is dismantled (and freed
> after RCU grace period)
> 
> And store in sockets not only the pointer to napi_struct, but the
> current generation id : If the generation id doesnt match, disable
> the spinpoll until next packet rebuilds the cache again.

This would require rcu_read_lock, aka preempt off, during polling, right?

-Andi

-- 
ak@linux.intel.com -- Speaking for myself only.
