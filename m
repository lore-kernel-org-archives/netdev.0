From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH] [RFC] tcp: TSQ - do not always throttle.
Date: Tue, 17 Jul 2012 19:38:57 +0530
Message-ID: <OFCF93D527.A65DD20D-ON65257A3E.004D15F6-65257A3E.004DCBB7@in.ibm.com>
References: <20120717120358.16611.98190.sendpatchset@localhost.localdomain> <1342530654.2626.563.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([122.248.162.4]:46347 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035Ab2GQOJw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jul 2012 10:09:52 -0400
Received: from /spool/local
	by e28smtp04.in.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <krkumar2@in.ibm.com>;
	Tue, 17 Jul 2012 19:39:49 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q6HE9lsl63176728
	for <netdev@vger.kernel.org>; Tue, 17 Jul 2012 19:39:47 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q6HJeRQ0017423
	for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 05:40:27 +1000
In-Reply-To: <1342530654.2626.563.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet <eric.dumazet@gmail.com> wrote on 07/17/2012 06:40:54 PM:

> > Do not throttle if sysctl_tcp_limit_output_bytes==0.
> >
> > Maybe it is better to throttle earlier in the loop, after
> > calling tcp_init_tso_segs().
> >
>
> I wonder why, and why you put this question in a changelog instead of
> outside of it...
>
> Idea was to avoid setting TSQ_THROTTLED if we break out the loop.

The reason I mentioned it (in the wrong place) is because
I thought this is a likely case and the checks before that
might all pass only to get throttled. Some of the checks
are quite lengthy.

> About disabling TSQ, my initial intent was to instead use a negative
> sysctl_tcp_limit_output_bytes value.
>
> Thats why I have in tcp_transmit_skb() :
>
> skb->destructor = (sysctl_tcp_limit_output_bytes > 0) ?
>         tcp_wfree : sock_wfree;
>
> So I suggest you change the tcp_write_xmit(() test to a single unsigned
> compare :
>
> if (atomic_read(&sk->sk_wmem_alloc) >=
>     (unsigned) sysctl_tcp_limit_output_bytes) {
>
> Also use :
>
> skb->destructor = (sysctl_tcp_limit_output_bytes >= 0) ?
>   tcp_wfree : sock_wfree;
>
> and document the 'negative value disables TSQ' in
> Documentation/networking/ip-sysctl.txt

Sure, will post with this change.

thanks,
- KK
