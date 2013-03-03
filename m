From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Sun, 03 Mar 2013 13:20:01 -0800
Message-ID: <1362345601.15793.83.camel@edumazet-glaptop>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
	 <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
	 <1362335704.15793.81.camel@edumazet-glaptop>
	 <20130303192153.GC3401@two.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eliezer Tamir <eliezer.tamir@linux.jf.intel.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dave Miller <davem@davemloft.net>,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>, HPA <hpa@zytor.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20130303192153.GC3401@two.firstfloor.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sun, 2013-03-03 at 20:21 +0100, Andi Kleen wrote:
> > Alternative to 2) would be to use a generation id, incremented every
> > time a napi used in spin polling enabled driver is dismantled (and freed
> > after RCU grace period)
> > 
> > And store in sockets not only the pointer to napi_struct, but the
> > current generation id : If the generation id doesnt match, disable
> > the spinpoll until next packet rebuilds the cache again.
> 
> This would require rcu_read_lock, aka preempt off, during polling, right?
> 

Of course, polling probably needs BH disabling as well to get the per
napi lock
