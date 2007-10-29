From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] inet: race in wait for connect.
Date: Mon, 29 Oct 2007 15:38:42 -0700 (PDT)
Message-ID: <20071029.153842.226361489.davem@davemloft.net>
References: <20071029135222.2ad073ff@freepuppy.rosehill>
	<20071029212906.GE21178@ghostprotocols.net>
	<20071029143714.152e0431@freepuppy.rosehill>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: shemminger@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54325
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752416AbXJ2Wik (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 18:38:40 -0400
In-Reply-To: <20071029143714.152e0431@freepuppy.rosehill>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>
Date: Mon, 29 Oct 2007 14:37:14 -0700

> On Mon, 29 Oct 2007 19:29:06 -0200
> "Arnaldo Carvalho de Melo" <acme@redhat.com> wrote:
> 
> > Em Mon, Oct 29, 2007 at 01:52:22PM -0700, Stephen Hemminger escreveu:
> > > Fix possible race while waiting for connections in accept. I don't
> > > know of a test case that could reproduce this directly.
> > > 
> > > The state of the socket should be checked before checking the queue.
> > > If the socket has left the TCP_LISTEN state, then the accept queue
> > > is no longer valid.
> > 
> > Well if it left from LISTEN to CLOSED inet_csk_listen_stop must have
> > been called, and that calls reqsk_queue_yank_acceptq, that sets it to
> > NULL, reqsk_queue_empty(&icsk->icsk_accept_queue) returns true and we
> > get to if (sk->sk_state != TCP_LISTEN), returning -EINVAL as with your
> > patch.  So I can't see a race, just one branch less in one case :-)
> > 
> > - Arnaldo
> 
> Yeah, your right. The listen queue is garbage at this point but the
> accept queue is always empty.

Is there some failing test case you are aware of which led
you to this piece of code or did you happen to notice it
while scanning around?
