From: Andrew Morton <akpm@osdl.org>
Subject: Re: 2.6.20-rc6-mm1
Date: Sun, 28 Jan 2007 22:43:12 -0800
Message-ID: <20070128224312.50f89360.akpm@osdl.org>
References: <45BD2424.7020604@googlemail.com>
	<E1HBOtk-0007dS-00@gondolin.me.apana.org.au>
	<20070129052929.GA29456@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Michal Piotrowski <michal.k.k.piotrowski@gmail.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Dipankar Sarma <dipankar@in.ibm.com>,
	"Paul E. McKenney" <paulmck@us.ibm.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:51734 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933242AbXA2Gw7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jan 2007 01:52:59 -0500
In-Reply-To: <20070129052929.GA29456@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Jan 2007 16:29:29 +1100
Herbert Xu <herbert@gondor.apana.org.au> wrote:

> On Mon, Jan 29, 2007 at 04:17:44PM +1100, Herbert Xu wrote:
> > Michal Piotrowski <michal.k.k.piotrowski@gmail.com> wrote:
> > 
> > > Jan 28 22:58:29 euridica kernel: BUG: using smp_processor_id() in preemptible [00000001] code: yum-updatesd/2846
> > > Jan 28 22:58:29 euridica kernel: caller is nf_conntrack_in+0x363/0x47f [nf_conntrack]
> > > Jan 28 22:58:29 euridica kernel:  [<c01053c6>] show_trace_log_lvl+0x1a/0x2f
> > > Jan 28 22:58:29 euridica kernel:  [<c0105ad6>] show_trace+0x12/0x14
> > > Jan 28 22:58:29 euridica kernel:  [<c0105b98>] dump_stack+0x16/0x18
> > > Jan 28 22:58:29 euridica kernel:  [<c0207803>] debug_smp_processor_id+0xb3/0xc8
> > > Jan 28 22:58:29 euridica kernel:  [<fdbf8ad0>] nf_conntrack_in+0x363/0x47f [nf_conntrack]
> > > Jan 28 22:58:29 euridica kernel:  [<fd9c32c4>] ipv4_conntrack_local+0x53/0x5b [nf_conntrack_ipv4]
> > > Jan 28 22:58:29 euridica kernel:  [<c02f2286>] nf_iterate+0x36/0x67
> > > Jan 28 22:58:29 euridica kernel:  [<c02f241b>] nf_hook_slow+0x52/0xbe
> > 
> > This shouldn't have happened.  nf_hook_slow calls nf_iterate and
> > therefore everything under it with preemption disabled.  So something
> > must've reenabled it before hitting nf_conntrack_in.
> 
> Does mm now have the preemptible RCU stuff? If so that would certainly
> explain this.

It does,

> IIRC Ingo had made fixes for the networking stack in his rt tree since
> the networking code assumes in lots of places that rcu_read_lock
> disables preemption.

oh.  We'd better find those fixes then.  I wonder what other code made that
(rather hacky) assumption?  I guess we have enough debug stuff in there to
find out..
