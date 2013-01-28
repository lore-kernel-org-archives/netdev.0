From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next] pktgen: support net namespace
Date: Mon, 28 Jan 2013 15:36:01 +0800
Message-ID: <1359358561.20444.14.camel@cr0>
References: <1359354775-28344-1-git-send-email-amwang@redhat.com>
	 <87d2wpyf27.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36098 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752974Ab3A1HgL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Jan 2013 02:36:11 -0500
In-Reply-To: <87d2wpyf27.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-01-27 at 22:52 -0800, Eric W. Biederman wrote:
> Cong Wang <amwang@redhat.com> writes:
> 
> > From: Cong Wang <amwang@redhat.com>
> >
> > This patch add net namespace to pktgen, so that
> > we can use pktgen in different namespaces.
> 
> Skimming through this looks like a reasonable patch.
> 
> I am not a fan of the number of threads, but that has nothing to do with
> correctness, and would certainly require a large change in logic to keep
> the number of threads down, which might not be a good idea.

Yeah, I noticed we would have nr_ns*nr_cpu threads after this patch,
unfortunately this is not easy to solve due to the interface of pktgen
by design.

> 
> 
> One small nit below.
...
> >  
> > -	pg_proc_dir = proc_mkdir(PG_PROC_DIR, init_net.proc_net);
> > -	if (!pg_proc_dir)
> > -		return -ENODEV;
> > +	pn->net = net;
> > +	if (!pn->proc_dir) {
>         ^^^^^^^^^^^^^^^^^^^^
> 
> This test is pointless.  pn->proc_dir is allocated with kzalloc so it
> will be initially NULL and pg_net_init will be called exactly once
> per network namespace so pn->proc_dir will always be NULL here. 
> 

Alright... will remove it.

Thanks!
