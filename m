From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [PATCH] net: fix race in the receive/select
Date: Sun, 28 Jun 2009 23:48:46 +0200
Message-ID: <20090628214846.GB4584@ami.dom.local>
References: <4A442B65.8040701@gmail.com> <alpine.DEB.1.10.0906251858520.9517@makko.or.mcafeemobile.com> <4A443033.8060401@gmail.com> <alpine.DEB.1.10.0906251947530.9517@makko.or.mcafeemobile.com> <20090626135742.GB3845@redhat.com> <alpine.DEB.1.10.0906261018580.16400@makko.or.mcafeemobile.com> <20090626145027.GA6534@redhat.com> <4A474FB5.4070901@gmail.com> <4A475266.9040203@gmail.com> <20090628180412.GA9171@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Davide Libenzi <davidel@xmailserver.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Jiri Olsa <jolsa@redhat.com>, netdev@vger.kernel.org,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	fbl@redhat.com, nhorman@redhat.com, davem@redhat.com,
	Tejun Heo <htejun@gmail.com>
To: Oleg Nesterov <oleg@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f218.google.com ([209.85.220.218]:51059 "EHLO
	mail-fx0-f218.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752949AbZF1Vs5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jun 2009 17:48:57 -0400
Content-Disposition: inline
In-Reply-To: <20090628180412.GA9171@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 28, 2009 at 08:04:12PM +0200, Oleg Nesterov wrote:
> On 06/28, Jarek Poplawski wrote:
...
> > Hmm... of course:
> >
> > static inline void sock_poll_wait(struct file * filp, struct sock *sk, poll_table *p)
> > {
> >  	if (p && sk->sk_sleep) {
> >  		__poll_wait(filp, sk->sk_sleep, p);
> >  		/*
> >  		 * fat comment
> >  		 */
> >  		smp_mb(); // or smp_mb__after_unlock();
> >  	}
> > }
> 
> Perhaps it makes sense to check ->sk_sleep != NULL in sock_poll_wait(), but
> I don't think we need __poll_wait(). poll_wait() is inline, I think gcc
> will optimize out "if (p && wait_address)" check if poll_wait() is called
> from sock_poll_wait().

Sure, to me it looks a bit more readable, but let Jiri choose.;-)

Cheers,
Jarek P. 
