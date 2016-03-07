From: Mike Galbraith <umgwanakikbuti@gmail.com>
Subject: Re: Softirq priority inversion from "softirq: reduce latencies"
Date: Mon, 07 Mar 2016 18:06:30 +0100
Message-ID: <1457370390.3635.6.camel@gmail.com>
References: <56D1E8B6.6090003@hurleysoftware.com>
	 <1456638957.3676.12.camel@gmail.com>
	 <20160228170109.GA16322@electric-eye.fr.zoreil.com>
	 <1456721889.3488.67.camel@gmail.com> <56DD9EE8.1010909@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Peter Hurley <peter@hurleysoftware.com>,
	Eric Dumazet <edumazet@google.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, Greg KH <gregkh@linuxfoundation.org>,
	dmaengine@vger.kernel.org, John Ogness <john.ogness@linutronix.de>,
	Andrew Morton <akpm@linux-foundation.org>
To: Sebastian Andrzej Siewior <bigeasy@linutronix.de>,
	Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f51.google.com ([74.125.82.51]:33988 "EHLO
	mail-wm0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752697AbcCGRGf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Mar 2016 12:06:35 -0500
In-Reply-To: <56DD9EE8.1010909@linutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2016-03-07 at 16:31 +0100, Sebastian Andrzej Siewior wrote:
> On 02/29/2016 05:58 AM, Mike Galbraith wrote:
> > WRT -rt: if dma tasklets really do have hard (ish) constraints, -rt
> > recently "broke" in the same way.. of all softirqs which are deferred
> > to kthread context, due to a recent change, only timer/hrtimer are
> > executed at realtime priority by default.
> 
> no. All softirqs are invoked in the context of the current process that
> triggerd the softirq invocation. If NAPI goes on for too long (or other
> softirq can't be executed in this context) it will continue in the
> ksoftirqd. And this threads runs at a normal priority like it does in
> mainline.
> I adjusted it with mainline.

Yeah, that's what I said, the ksoftirqd case became the same in -rt.

	-Mike
