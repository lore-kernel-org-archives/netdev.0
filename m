From: "Denis V. Lunev" <den@openvz.org>
Subject: Re: 2.6.27-rc4: icmp_sk() uses smp_processor_id() in preemptible
	code
Date: Fri, 22 Aug 2008 17:12:37 +0400
Message-ID: <1219410757.31440.1.camel@iris.sw.ru>
References: <20080821122040.GA2497@x200.localdomain>
	 <E1KW9c0-0002Kp-00@gondolin.me.apana.org.au>
	 <20080822.045402.32679253.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, adobriyan@gmail.com,
	dlezcano@fr.ibm.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:11024 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751442AbYHVNNe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Aug 2008 09:13:34 -0400
In-Reply-To: <20080822.045402.32679253.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2008-08-22 at 04:54 -0700, David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Thu, 21 Aug 2008 22:50:00 +1000
> 
> > adobriyan@gmail.com wrote:
> > > Steps to reproduce:
> > > 
> > >        CONFIG_PREEMPT=y
> > >        CONFIG_DEBUG_PREEMPT=y
> > >        tracepath <something>
> > > 
> > > icmp6_sk() is similar (I haven't checked at runtime, though).
> > > 
> > > BUG: using smp_processor_id() in preemptible [00000000] code: tracepath/3205
> > > caller is icmp_sk+0x15/0x30
> > > Pid: 3205, comm: tracepath Not tainted 2.6.27-rc4 #1
> > > 
> > > Call Trace:
> > > [<ffffffff8031af14>] debug_smp_processor_id+0xe4/0xf0
> > > [<ffffffff80409405>] icmp_sk+0x15/0x30
> > > [<ffffffff8040a17b>] icmp_send+0x4b/0x3f0
> > 
> > Caused by:
> > 
> > commit 405666db84b984b68fc75794069f424c02e5796c
> > Author: Denis V. Lunev <den@openvz.org>
> > Date:   Fri Feb 29 11:16:46 2008 -0800
> > 
> >     [ICMP]: Pass proper ICMP socket into icmp(v6)_xmit_(un)lock.
> > 
> > We need to disable preemption (was provided by disabling BH) before
> > getting the per-cpu ICMP socket.
> 
> Denis, please fix this.
> 
> The icmp_sk was always evaluated inside of icmp*_xmit_lock()
> exactly because we needed the BH disabling in order for the
> smp_processor_id() evaluation to be safe.
> 
> It's probably better to pass the namespace into the lock and
> unlock routines.

for sure. I am sorry for the delay, I am ill and at home.

I'll try to do my best and cook the patch today.

