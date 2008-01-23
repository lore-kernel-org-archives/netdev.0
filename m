From: Krishna Kumar2 <krkumar2@in.ibm.com>
Subject: Re: Assertions in latest kernels
Date: Wed, 23 Jan 2008 13:52:53 +0530
Message-ID: <OF331AFFAC.CEF61228-ON652573D9.002CF47B-652573D9.002E0A84@in.ibm.com>
References: <20080122.235723.52174015.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e28smtp06.in.ibm.com ([59.145.155.6]:46961 "EHLO
	e28esmtp06.in.ibm.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751113AbYAWIZV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jan 2008 03:25:21 -0500
Received: from d28relay02.in.ibm.com (d28relay02.in.ibm.com [9.184.220.59])
	by e28esmtp06.in.ibm.com (8.13.1/8.13.1) with ESMTP id m0N8PIiW004369
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:18 +0530
Received: from d28av02.in.ibm.com (d28av02.in.ibm.com [9.184.220.64])
	by d28relay02.in.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0N8PIoS1089780
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 13:55:18 +0530
Received: from d28av02.in.ibm.com (loopback [127.0.0.1])
	by d28av02.in.ibm.com (8.13.1/8.13.3) with ESMTP id m0N8PIGh023889
	for <netdev@vger.kernel.org>; Wed, 23 Jan 2008 08:25:18 GMT
In-Reply-To: <20080122.235723.52174015.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote on 01/23/2008 01:27:23 PM:

> > iperf with multiple threads almost always gets these 4, *especially*
when I
> > do some batching :).
> >
> > static void tcp_fastretrans_alert(struct sock *sk, int pkts_acked, int
flag)
> > {
> >       ...
> >       if (WARN_ON(!tp->sacked_out && tp->fackets_out))
> >             tp->fackets_out = 0;
> >       ...
> > }
>
> Does this assertion show up first or do you get the other TCP
> ones first?  It might be important, in that if you get the
> others ones first that corrupted state might be what leads to
> this one.

Hi Dave,

I looked at my *old* messages file and found this assert (2506) was first
to hit (atleast in
two messages file). It hit 5 times, then I got a different one that I had
not reported earlier:

"KERNEL: assertion (packets <= tp->packets_out) failed at
net/ipv4/tcp_input.c (2139)"

(though this was hidden in my report under the panic for tcp_input.c:2528.

Then another two thousand times of the 2506 asserts.

Today I installed the latest untouched kernel, rebooted system and got the
following errors
in sequence, but no 2506 errors (which I have always got when running
batching in the last
2-3 weeks):

Jan 22 02:07:55 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:56 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:56 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:57 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:58 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:59 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:07:59 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:00 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:01 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:01 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:02 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:03 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:03 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:04 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:05 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:06 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:06 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:07 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 22 02:08:07 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:08 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:09 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:10 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:10 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:11 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:12 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:13 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:14 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:15 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:15 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 22 02:08:16 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 22 02:08:16 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:1767
Jan 22 02:08:17 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:18 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:18 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169
Jan 22 02:08:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2528
Jan 22 02:08:19 elm3b39 kernel: Badness at net/ipv4/tcp_input.c:2169

and so on for another 700 counts.

The unique asserts are:
      1767: tcp_verify_left_out (from tcp_entry_frto)
      2169: tcp_verify_left_out (from tcp_mark_head_lost)
      2528: tcp_verify_left_out (from tcp_fastretrans_alert)
      3063: tcp_verify_left_out (from tcp_process_frto)
(where 2169 seems to preceed any other asserts)

The other two asserts that I got only with batching are:
      2139: BUG_TRAP(packets <= tp->packets_out); (in tcp_mark_head_lost)
      2506: WARN_ON(!tp->sacked_out && tp->fackets_out) (in
tcp_fastretrans_alert)
(where 2506 always seems to preceed any other asserts).

thanks,

- KK

