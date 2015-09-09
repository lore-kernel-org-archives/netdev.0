From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Wed, 9 Sep 2015 14:59:19 +0200
Message-ID: <20150909145919.4d68ea36@redhat.com>
References: <20150824005727.2947.36065.stgit@localhost>
	<20150904165944.4312.32435.stgit@devil>
	<55E9DE51.7090109@gmail.com>
	<alpine.DEB.2.11.1509041354560.993@east.gentwo.org>
	<55EA0172.2040505@gmail.com>
	<alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
	<20150905131825.6c04837d@redhat.com>
	<alpine.DEB.2.11.1509081228100.26148@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Alexander Duyck <alexander.duyck@gmail.com>, netdev@vger.kernel.org,
        akpm@linux-foundation.org, linux-mm@kvack.org,
        aravinda@linux.vnet.ibm.com,
        "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
        iamjoonsoo.kim@lge.com, brouer@redhat.com
To: Christoph Lameter <cl@linux.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <alpine.DEB.2.11.1509081228100.26148@east.gentwo.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On Tue, 8 Sep 2015 12:32:40 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Sat, 5 Sep 2015, Jesper Dangaard Brouer wrote:
> 
> > The double_cmpxchg without lock prefix still cost 9 cycles, which is
> > very fast but still a cost (add approx 19 cycles for a lock prefix).
> >
> > It is slower than local_irq_disable + local_irq_enable that only cost
> > 7 cycles, which the bulking call uses.  (That is the reason bulk calls
> > with 1 object can almost compete with fastpath).
> 
> Hmmm... Guess we need to come up with distinct version of kmalloc() for
> irq and non irq contexts to take advantage of that . Most at non irq
> context anyways.

I agree, it would be an easy win.  Do notice this will have the most
impact for the slAb allocator.

I estimate alloc + free cost would save:
 * slAb would save approx 60 cycles
 * slUb would save approx  4 cycles

We might consider keeping the slUb approach as it would be more
friendly for RT with less IRQ disabling.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
