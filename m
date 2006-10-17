From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Bound TSO defer time (resend)
Date: Mon, 16 Oct 2006 22:35:13 -0700 (PDT)
Message-ID: <20061016.223513.35356292.davem@davemloft.net>
References: <Pine.LNX.4.58.0610162051170.12462@dexter.psc.edu>
	<20061016202035.6d55b96e@localhost.localdomain>
	<45345999.4000300@psc.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16833
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1423115AbWJQFfM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Oct 2006 01:35:12 -0400
To: jheffner@psc.edu
In-Reply-To: <45345999.4000300@psc.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Heffner <jheffner@psc.edu>
Date: Tue, 17 Oct 2006 00:18:33 -0400

> Stephen Hemminger wrote:
> > On Mon, 16 Oct 2006 20:53:20 -0400 (EDT)
> > John Heffner <jheffner@psc.edu> wrote:
> 
> >> This patch limits the amount of time you will defer sending a TSO segment
> >> to less than two clock ticks, or the time between two acks, whichever is
> >> longer.
> 
> > 
> > Okay, but doing any timing on clock ticks makes the behavior dependent
> > on the value of HZ which doesn't seem desirable. Should this be based
> > on RTT or a real-time values?
> 
> It would be nice to use a high res clock so you don't depend on HZ, but 
> this is still expensive on most SMP arch's as I understand it.

Right so we do need to use a jiffies based solution.

Since HZ is variable, I have a feeling that the thing to do here
is pick some timeout in msec.  Then replace the "2 clock ticks"
with some msec_to_jiffies() calls, bottoming out at 1 jiffie.

How does that sound?
