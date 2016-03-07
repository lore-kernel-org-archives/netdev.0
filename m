From: Sebastian Andrzej Siewior <bigeasy@linutronix.de>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 7 Mar 2016 16:31:52 +0100
Message-ID: <56DD9EE8.1010909@linutronix.de>
References: <56D1E8B6.6090003@hurleysoftware.com>
 <1456638957.3676.12.camel@gmail.com>
 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
 <1456721889.3488.67.camel@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Mike Galbraith <umgwanakikbuti@gmail.com>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.linutronix.de ([62.245.132.108]:45435 "EHLO
	Galois.linutronix.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752413AbcCGPb5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 10:31:57 -0500
In-Reply-To: <1456721889.3488.67.camel@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/29/2016 05:58 AM, Mike Galbraith wrote:
> WRT -rt: if dma tasklets really do have hard (ish) constraints, -rt
> recently "broke" in the same way.. of all softirqs which are deferred
> to kthread context, due to a recent change, only timer/hrtimer are
> executed at realtime priority by default.

no. All softirqs are invoked in the context of the current process that
triggerd the softirq invocation. If NAPI goes on for too long (or other
softirq can't be executed in this context) it will continue in the
ksoftirqd. And this threads runs at a normal priority like it does in
mainline.
I adjusted it with mainline.

> 	-Mike
> 
Sebastian
