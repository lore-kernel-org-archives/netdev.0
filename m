From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [PATCH 36/38] netfilter: connlimit: use keyed locks
Date: Tue, 18 Mar 2014 14:46:16 +0100
Message-ID: <20140318144616.0c568cbb@redhat.com>
References: <1395060178-11833-1-git-send-email-pablo@netfilter.org>
	<1395060178-11833-37-git-send-email-pablo@netfilter.org>
	<1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: brouer@redhat.com, Pablo Neira Ayuso <pablo@netfilter.org>,
	netfilter-devel@vger.kernel.org, davem@davemloft.net,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1395064808.9668.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 17 Mar 2014 07:00:08 -0700
Eric Dumazet <eric.dumazet@gmail.com> wrote:

> On Mon, 2014-03-17 at 13:42 +0100, Pablo Neira Ayuso wrote:
> > From: Florian Westphal <fw@strlen.de>
> > 
> > connlimit currently suffers from spinlock contention, example for
> > 4-core system with rps enabled:
> 
> > +#define CONNLIMIT_SLOTS	256
> > +#define CONNLIMIT_LOCK_SLOTS	32
> 
> 
> 
> 32 spinlocks use 2 cache lines (assuming 4 bytes per spinlock, and 64
> bytes cache lines)

Hehe, I actually also pointed this out during my internal review, but
we never gotten around to fixing this.

> So I guess this probably should be increased to have less false sharing.
> 
> Note: This can be done later, I do not want to block this patch serie at
> all !

Yes, lets fix it up later.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
