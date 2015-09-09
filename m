From: Christoph Lameter <cl@linux.com>
Subject: Re: [RFC PATCH 0/3] Network stack, first user of SLAB/kmem_cache
 bulk free API.
Date: Wed, 9 Sep 2015 09:08:47 -0500 (CDT)
Message-ID: <alpine.DEB.2.11.1509090907240.18992@east.gentwo.org>
References: <20150824005727.2947.36065.stgit@localhost> <20150904165944.4312.32435.stgit@devil> <55E9DE51.7090109@gmail.com> <alpine.DEB.2.11.1509041354560.993@east.gentwo.org> <55EA0172.2040505@gmail.com> <alpine.DEB.2.11.1509041844190.2499@east.gentwo.org>
 <20150905131825.6c04837d@redhat.com> <alpine.DEB.2.11.1509081228100.26148@east.gentwo.org> <20150909145919.4d68ea36@redhat.com>
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexander Duyck <alexander.duyck@gmail.com>,
	netdev@vger.kernel.org, akpm@linux-foundation.org,
	linux-mm@kvack.org, aravinda@linux.vnet.ibm.com,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	iamjoonsoo.kim@lge.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from resqmta-ch2-08v.sys.comcast.net ([69.252.207.40]:53727 "EHLO
	resqmta-ch2-08v.sys.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751469AbbIIOIu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Sep 2015 10:08:50 -0400
In-Reply-To: <20150909145919.4d68ea36@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Sep 2015, Jesper Dangaard Brouer wrote:

> > Hmmm... Guess we need to come up with distinct version of kmalloc() for
> > irq and non irq contexts to take advantage of that . Most at non irq
> > context anyways.
>
> I agree, it would be an easy win.  Do notice this will have the most
> impact for the slAb allocator.
>
> I estimate alloc + free cost would save:
>  * slAb would save approx 60 cycles
>  * slUb would save approx  4 cycles
>
> We might consider keeping the slUb approach as it would be more
> friendly for RT with less IRQ disabling.

IRQ disabling it a mixed bag. Older cpus have higher latencies there and
also virtualized contexts may require the hypervisor tracks the interrupt
state.

For recent intel cpus this is certainly a workable approach.
