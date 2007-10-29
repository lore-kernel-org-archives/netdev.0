From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] inet: race in wait for connect.
Date: Mon, 29 Oct 2007 16:16:18 -0700
Message-ID: <20071029161618.06bb4689@freepuppy.rosehill>
References: <20071029135222.2ad073ff@freepuppy.rosehill>
	<20071029212906.GE21178@ghostprotocols.net>
	<20071029143714.152e0431@freepuppy.rosehill>
	<20071029.153842.226361489.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: acme@redhat.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:46032 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752477AbXJ2XRD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 19:17:03 -0400
In-Reply-To: <20071029.153842.226361489.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 15:38:42 -0700 (PDT)
David Miller <davem@davemloft.net> wrote:

> From: Stephen Hemminger <shemminger@linux-foundation.org>
> Date: Mon, 29 Oct 2007 14:37:14 -0700
> 
> > On Mon, 29 Oct 2007 19:29:06 -0200
> > "Arnaldo Carvalho de Melo" <acme@redhat.com> wrote:
> > 
> > > Em Mon, Oct 29, 2007 at 01:52:22PM -0700, Stephen Hemminger escreveu:
> > > > Fix possible race while waiting for connections in accept. I don't
> > > > know of a test case that could reproduce this directly.
> > > > 
> > > > The state of the socket should be checked before checking the queue.
> > > > If the socket has left the TCP_LISTEN state, then the accept queue
> > > > is no longer valid.
> > > 
> > > Well if it left from LISTEN to CLOSED inet_csk_listen_stop must have
> > > been called, and that calls reqsk_queue_yank_acceptq, that sets it to
> > > NULL, reqsk_queue_empty(&icsk->icsk_accept_queue) returns true and we
> > > get to if (sk->sk_state != TCP_LISTEN), returning -EINVAL as with your
> > > patch.  So I can't see a race, just one branch less in one case :-)
> > > 
> > > - Arnaldo
> > 
> > Yeah, your right. The listen queue is garbage at this point but the
> > accept queue is always empty.
> 
> Is there some failing test case you are aware of which led
> you to this piece of code or did you happen to notice it
> while scanning around?

While instrumenting the snot out of accept logic for looking at alternatives
to the MT-accept vs. close issue.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
