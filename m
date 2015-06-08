From: Jesper Dangaard Brouer <brouer@redhat.com>
Subject: Re: [RFC PATCH] slub: RFC: Improving SLUB performance with 38% on
 NO-PREEMPT
Date: Mon, 8 Jun 2015 11:58:42 +0200
Message-ID: <20150608115842.694856ff@redhat.com>
References: <20150604103159.4744.75870.stgit@ivy>
	<1433471877.1895.51.camel@edumazet-glaptop2.roam.corp.google.com>
	<20150608112359.04a3750e@redhat.com>
	<alpine.DEB.2.11.1506080438570.10781@east.gentwo.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Joonsoo Kim <iamjoonsoo.kim@lge.com>,
	Alexander Duyck <alexander.duyck@gmail.com>,
	linux-mm@kvack.org, netdev@vger.kernel.org, brouer@redhat.com
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:60677 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751186AbbFHJ6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2015 05:58:48 -0400
In-Reply-To: <alpine.DEB.2.11.1506080438570.10781@east.gentwo.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 8 Jun 2015 04:39:38 -0500 (CDT)
Christoph Lameter <cl@linux.com> wrote:

> On Mon, 8 Jun 2015, Jesper Dangaard Brouer wrote:
> 
> > My real question is if disabling local interrupts is enough to avoid this?
> 
> Yes the initial release of slub used interrupt disable in the fast paths.

Thanks for the confirmation.

For this code path we would need the save/restore variant, which is
more expensive than the local cmpxchg16b.   In case of bulking, we
should be able to use the less expensive local_irq_{disable,enable}.

Cost of local IRQ toggling (CPU E5-2695):
 *  local_irq_{disable,enable}:  7 cycles(tsc) -  2.861 ns
 *  local_irq_{save,restore}  : 37 cycles(tsc) - 14.846 ns

p.s. I'm back working on bulking API...

> > And, does local irq disabling also stop preemption?
> 
> Of course.

Thanks for confirming this.

-- 
Best regards,
  Jesper Dangaard Brouer
  MSc.CS, Sr. Network Kernel Developer at Red Hat
  Author of http://www.iptv-analyzer.org
  LinkedIn: http://www.linkedin.com/in/brouer
