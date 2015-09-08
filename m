From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Tue, 8 Sep 2015 12:32:40 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509081228100.26148@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com> <alpine.DEB.2.11.1509041354560.993@east.gentwo.org> <55EA0172.2040505@gmail.com> <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
 <20150905131825.6c04837d@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-mm@kvack.org, aravinda@linux.vnet.ibm.com,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	iamjoonsoo.kim@lge.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-03v.sys.comcast.net ([69.252.207.35]:43580 "EHLO
	resqmta-ch2-03v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752709AbbIHRcl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Sep 2015 13:32:41 -0400
In-Reply-To: <20150905131825.6c04837d@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 5 Sep 2015, Jesper Dangaard Brouer wrote:

> The double_cmpxchg without lock prefix still cost 9 cycles, which is
> very fast but still a cost (add approx 19 cycles for a lock prefix).
>
> It is slower than local_irq_disable + local_irq_enable that only cost
> 7 cycles, which the bulking call uses.  (That is the reason bulk calls
> with 1 object can almost compete with fastpath).

Hmmm... Guess we need to come up with distinct version of kmalloc() for
irq and non irq contexts to take advantage of that . Most at non irq
context anyways.
