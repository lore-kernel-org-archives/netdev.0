From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH net] 6lowpan: add missing fragment
	list spinlock
Date: Wed, 5 Feb 2014 08:47:30 +0100
Message-ID: <20140205074729.GA27973@omega>
References: <1391511473-30000-1-git-send-email-alex.aring@gmail.com>
	<20140204.203203.1380460749447396879.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20140204.203203.1380460749447396879.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi David,

thanks for your reply.

On Tue, Feb 04, 2014 at 08:32:03PM -0800, David Miller wrote:
> From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Date: Tue,  4 Feb 2014 11:57:53 +0100
> 
> > @@ -197,7 +197,9 @@ static void lowpan_fragment_timer_expired(unsigned long entry_addr)
> >  
> >  	pr_debug("timer expired for frame with tag %d\n", entry->tag);
> >  
> > +	spin_lock_bh(&flist_lock);
> >  	list_del(&entry->list);
> > +	spin_unlock_bh(&flist_lock);
> >  	dev_kfree_skb(entry->skb);
> >  	kfree(entry);
> >  }
> 
> This will deadlock, because the other code path holding flist_lock calls
> del_timer_sync() to wait for this timer to return.
> 
ok. I detected this some months ago and I talked with Werner Almesberger
about that. He talked something about del_timer_sync too and other
issues, but I didn't understand that I open a new deadlock case. Now I
learned something new things, thanks. :-)

> The synchornization in this code is really a big mess.

That is one thing which I also detected so I decide to make a new
implementation based on net/ipv6/reassembly.c which also used the
inet_frag api.

I will bring these patches mainline and I hope it will remove the most
of the race condigition. But then it's only solved in net-next branch.

- Alex

------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
