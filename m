From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Mon, 16 Oct 2006 20:20:35 -0700
Message-ID: <20061016202035.6d55b96e@localhost.localdomain>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:64913 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1422750AbWJQDU6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2006 23:20:58 -0400
To: John Heffner <jheffner@psc.edu>
In-Reply-To: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
John Heffner <jheffner@psc.edu> wrote:

> The original message didn't show up on the list.  I'm assuming it's
> because the filters didn't like the attached postscript.  I posted PDFs of
> the figures on the web:
> 
> http://www.psc.edu/~jheffner/tmp/a.pdf
> http://www.psc.edu/~jheffner/tmp/b.pdf
> http://www.psc.edu/~jheffner/tmp/c.pdf
> 
>   -John
> 
> 
> ---------- Forwarded message ----------
> Date: Mon, 16 Oct 2006 15:55:53 -0400 (EDT)
> From: John Heffner <jheffner@psc.edu>
> To: David Miller <davem@davemloft.net>
> Cc: netdev <netdev@vger.kernel.org>
> Subject: [PATCH] Bound TSO defer time
> 
> This patch limits the amount of time you will defer sending a TSO segment
> to less than two clock ticks, or the time between two acks, whichever is
> longer.
> 
> On slow links, deferring causes significant bursts.  See attached plots,
> which show RTT through a 1 Mbps link with a 100 ms RTT and ~100 ms queue
> for (a) non-TSO, (b) currnet TSO, and (c) patched TSO.  This burstiness
> causes significant jitter, tends to overflow queues early (bad for short
> queues), and makes delay-based congestion control more difficult.
> 
> Deferring by a couple clock ticks I believe will have a relatively small
> impact on performance.
> 
> 
> Signed-off-by: John Heffner <jheffner@psc.edu>

Okay, but doing any timing on clock ticks makes the behavior dependent
on the value of HZ which doesn't seem desirable. Should this be based
on RTT or a real-time values?
