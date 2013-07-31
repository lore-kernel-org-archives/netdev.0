From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: [PATCH net] ipv6: prevent fib6_run_gc() contention
Date: Thu, 1 Aug 2013 00:19:31 +0200
Message-ID: <20130731221931.GA27754@lion.mk-sys.cz>
References: <20130611100718.GA7581@unicorn.suse.cz>
 <20130611.130114.764345999553478927.davem@davemloft.net>
 <20130611204912.GA1255@lion.mk-sys.cz>
 <20130611.142229.497972115797274443.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Eric Dumazet <eric.dumazet@gmail.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lion.mk-sys.cz ([213.168.178.121]:33171 "EHLO lion.mk-sys.cz"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753079Ab3GaW3f (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 31 Jul 2013 18:29:35 -0400
Content-Disposition: inline
In-Reply-To: <20130611.142229.497972115797274443.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 11, 2013 at 02:22:29PM -0700, David Miller wrote:
> From: Michal Kubecek <mkubecek@suse.cz>
> Date: Tue, 11 Jun 2013 22:49:12 +0200
> 
> > On Tue, Jun 11, 2013 at 01:01:14PM -0700, David Miller wrote:
> >> From: Michal Kubecek <mkubecek@suse.cz>
> >> Date: Tue, 11 Jun 2013 12:07:18 +0200
> >> 
> >> > On Mon, Jun 10, 2013 at 02:26:42PM -0700, David Miller wrote:
> >> >> 
> >> >> It seems to me that it would be much simpler to simply update
> >> >> ip6_rt_last_gc first, that way the other threads would elide the GC
> >> >> call.
> >> > 
> >> > That was my original idea but I was afraid that while the remaining
> >> > window in ip6_dst_gc() would be very short and probably safe, we could
> >> > still run into problem if fib6_gc_lock was locked by some other caller
> >> > of fib6_run_gc() which doesn't update net->ipv6.ip6_rt_last_gc,
> >> > especially via a timer.
> >> 
> >> Why don't you simply try it and find out?
> > 
> > I don't have the system where the issue was observed at hand. I'll have
> > to ask the customer who reported it to run the test so that it may take
> > some time.
> 
> Please also take care of the issue Eric mentioned, in that some GC
> calls erroneously do not update the last GC timestamp.

I received the feedback today. The customer reported the patch moving
update of ip6_rt_last_gc into fib6_run_gc() before the call of
fib6_clean_all() was not sufficient to prevent the contention with their
workload.

So I suggest to return back to the approach I submitted originally but
to move the update into fib6_run_gc() anyway so that every run of the
garbage collector updates it. I will submit the patches tomorrow.

                                                        Michal Kubecek
