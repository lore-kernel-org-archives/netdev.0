From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: [PATCH 4/4 v3] net: Fix for dst_negative_advice
Date: Mon, 19 Oct 2009 10:04:53 +0530
Message-ID: <OF47BDCCCB.33D1775A-ON65257654.00178901-65257654.00192AA2@in.ibm.com>
References: <20091018130727.3960.32107.sendpatchset@localhost.localdomain>	<20091018130816.3960.87384.sendpatchset@localhost.localdomain> <20091019131209.1c782c8a@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: dada1@cosmosbay.com, davem@davemloft.net,
	herbert@gondor.apana.org.au, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp04.in.ibm.com ([59.145.155.4]:60651 "EHLO
	e28smtp04.in.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750999AbZJSEfo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 00:35:44 -0400
Received: from d28relay01.in.ibm.com (d28relay01.in.ibm.com [9.184.220.58])
	by e28smtp04.in.ibm.com (8.14.3/8.13.1) with ESMTP id n9J4Zlds031540
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 10:05:47 +0530
Received: from d28av06.in.ibm.com (d28av06.in.ibm.com [9.184.220.48])
	by d28relay01.in.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id n9J4ZlNw2265324
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 10:05:47 +0530
Received: from d28av06.in.ibm.com (loopback [127.0.0.1])
	by d28av06.in.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id n9J4Zka1018655
	for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 10:05:47 +0530
In-Reply-To: <20091019131209.1c782c8a@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com>  wrote on 10/19/2009 09:42:09 AM:

> > diff -ruNp org/net/ipv4/tcp_timer.c new/net/ipv4/tcp_timer.c
> > --- org/net/ipv4/tcp_timer.c   2009-10-16 21:30:56.000000000 +0530
> > +++ new/net/ipv4/tcp_timer.c   2009-10-16 21:31:30.000000000 +0530
> > @@ -141,14 +141,14 @@ static int tcp_write_timeout(struct sock
> >
> >     if ((1 << sk->sk_state) & (TCPF_SYN_SENT | TCPF_SYN_RECV)) {
> >        if (icsk->icsk_retransmits)
> > -         dst_negative_advice(&sk->sk_dst_cache);
> > +         dst_negative_advice(&sk->sk_dst_cache, sk);
> >        retry_until = icsk->icsk_syn_retries ? : sysctl_tcp_syn_retries;
> >     } else {
> >        if (retransmits_timed_out(sk, sysctl_tcp_retries1)) {
> >           /* Black hole detection */
> >           tcp_mtu_probing(icsk, sk);
> >
> > -         dst_negative_advice(&sk->sk_dst_cache);
> > +         dst_negative_advice(&sk->sk_dst_cache, sk);
> >        }
> >
> >        retry_until = sysctl_tcp_retries2;
>
> It is good that your patch is broken in pieces, but will the intermediate
patches
> still function correctly. I.e are they bisect safe?

I have only compile tested each patch, but I assume it could break
something.
Individual patches can be made to function correctly by renaming patch#2 to
patch#4 and move patch#3 and #4 ahead.

Should I resubmit with the changed order?

Thanks,

- KK

