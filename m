From: Christoph Lameter <cl@linux-foundation.org>
Subject: Re: UDP regression with packets rates < 10k per sec
Date: Tue, 15 Sep 2009 16:25:43 -0400 (EDT)
Message-ID: <alpine.DEB.1.10.0909151550200.3340@V090114053VZO-1>
References: <alpine.DEB.1.10.0909081820030.7733@V090114053VZO-1> <4AA6E039.4000907@gmail.com> <alpine.DEB.1.10.0909091000200.28070@V090114053VZO-1> <4AA7C512.6040100@gmail.com> <alpine.DEB.1.10.0909091234360.15538@V090114053VZO-1> <4AA7E082.90807@gmail.com>
 <alpine.DEB.1.10.0909091350590.32067@V090114053VZO-1> <4AA963A4.5080509@gmail.com> <4AA97183.3030008@gmail.com> <alpine.DEB.1.10.0909101741520.9964@V090114053VZO-1> <alpine.DEB.1.10.0909141708150.8051@V090114053VZO-1> <4AAF263E.9010405@gmail.com>
 <alpine.DEB.1.10.0909151000230.20318@V090114053VZO-1> <4AAFCE3A.8060102@gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.ultrahosting.com ([74.213.174.253]:54389 "EHLO
	smtp.ultrahosting.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1758058AbZIOU1w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Sep 2009 16:27:52 -0400
Received: from localhost (smtp.ultrahosting.com [127.0.0.1])
	by smtp.ultrahosting.com (Postfix) with ESMTP id B858982C66A
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 16:29:28 -0400 (EDT)
Received: from smtp.ultrahosting.com ([74.213.174.253])
	by localhost (smtp.ultrahosting.com [127.0.0.1]) (amavisd-new, port 10024)
	with ESMTP id Qb5LoEcmZVVz for <netdev@vger.kernel.org>;
	Tue, 15 Sep 2009 16:29:23 -0400 (EDT)
Received: from V090114053VZO-1 (unknown [74.213.171.31])
	by smtp.ultrahosting.com (Postfix) with ESMTP id DE95E82C68A
	for <netdev@vger.kernel.org>; Tue, 15 Sep 2009 16:29:23 -0400 (EDT)
In-Reply-To: <4AAFCE3A.8060102@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Sep 2009, Eric Dumazet wrote:

> Once I understood my 2.6.31 kernel had much more features than 2.6.22 and that I tuned
> it to :
>
> - Let cpu run at full speed (3GHz instead of 2GHz) : before tuning, 2.6.31 was
> using "ondemand" governor and my cpus were running at 2GHz, while they where
> running at 3GHz on my 2.6.22 config

My kernel did not have support for any governors compiled in.

> - Dont let cpus enter C2/C3 wait states (idle=mwait)

Ok. Trying idle=mwait.

> - Correctly affine cpu to ethX irq (2.6.22 was running ethX irq on one cpu, while
>  on 2.6.31, irqs were distributed to all online cpus)

Interrupts of both 2.6.22 and 2.6.31 go to cpu 0. Does it matter for
loopback?

> Then, your mcast test gives same results, at 10pps, 100pps, 1000pps, 10000pps

loopback via mcast -Ln1 -r <rate>

		10pps	100pps	1000pps	10000pps
2.6.22(32bit)	7.36	7.28	7.15	7.16
2.6.31(64bit)	9.28	10.27	9.70	9.79

What a difference. Now the initial latency rampup for 2.6.31 is gone. So
even w/o governors the kernel does something to increase the latencies.

We sacrificed 2 - 3 microseconds per message to kernel features, bloat and
64 bitness?
