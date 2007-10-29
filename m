From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] inet: race in wait for connect.
Date: Mon, 29 Oct 2007 14:37:14 -0700
Message-ID: <20071029143714.152e0431@freepuppy.rosehill>
References: <20071029135222.2ad073ff@freepuppy.rosehill>
	<20071029212906.GE21178@ghostprotocols.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Arnaldo Carvalho de Melo" <acme@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:57051 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751574AbXJ2Vh6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Oct 2007 17:37:58 -0400
In-Reply-To: <20071029212906.GE21178@ghostprotocols.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 29 Oct 2007 19:29:06 -0200
"Arnaldo Carvalho de Melo" <acme@redhat.com> wrote:

> Em Mon, Oct 29, 2007 at 01:52:22PM -0700, Stephen Hemminger escreveu:
> > Fix possible race while waiting for connections in accept. I don't
> > know of a test case that could reproduce this directly.
> > 
> > The state of the socket should be checked before checking the queue.
> > If the socket has left the TCP_LISTEN state, then the accept queue
> > is no longer valid.
> 
> Well if it left from LISTEN to CLOSED inet_csk_listen_stop must have
> been called, and that calls reqsk_queue_yank_acceptq, that sets it to
> NULL, reqsk_queue_empty(&icsk->icsk_accept_queue) returns true and we
> get to if (sk->sk_state != TCP_LISTEN), returning -EINVAL as with your
> patch.  So I can't see a race, just one branch less in one case :-)
> 
> - Arnaldo

Yeah, your right. The listen queue is garbage at this point but the
accept queue is always empty.


-- 
Stephen Hemminger <shemminger@linux-foundation.org>
