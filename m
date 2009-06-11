From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH 3/3] qlge: Increase default TX/RX ring size to
 1024.
Date: Thu, 11 Jun 2009 08:34:19 -0700
Message-ID: <20090611083419.4c173558@nehalam>
References: <1244684975-10211-1-git-send-email-ron.mercer@qlogic.com>
	<1244684975-10211-3-git-send-email-ron.mercer@qlogic.com>
	<20090611.022713.35602614.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: ron.mercer@qlogic.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:37484 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752490AbZFKPeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 11 Jun 2009 11:34:22 -0400
In-Reply-To: <20090611.022713.35602614.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 11 Jun 2009 02:27:13 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Ron Mercer <ron.mercer@qlogic.com>
> Date: Wed, 10 Jun 2009 18:49:35 -0700
> 
> > 
> > Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
> 
> This is huge.  Even other aggressive NICs such as BNX2X only use 256
> ring entries per TX queue.
> 
> There is a point where increasing definitely hurts, because you're
> increasing the resident set size of the cpu, as more and more SKBs are
> effectively "in flight" at a given time and only due to the amount
> you're allowing to get queued up into the chip.
> 
> And with multiqueue, per-queue TX queue sizes should matter less at
> least to some extent.
> 
> Are you sure that jacking the value up this high has no negative side
> effects for various workloads?

I am investigating reducing the sky2 default tx ring size down to
128 after user complaints about the latency. At 10G 1024 ring
entries is 7ms for jumbo frames.
