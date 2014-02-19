From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH -next] net: tcp: add mib counters to track zero window transitions
Date: Wed, 19 Feb 2014 20:30:38 +0100
Message-ID: <20140219193038.GC1179@order.stressinduktion.org>
References: <1392674268-26005-1-git-send-email-fw@strlen.de> <20140219.131708.562226572566677127.davem@davemloft.net> <1392835787.18849.11.camel@edumazet-glaptop2.roam.corp.google.com> <20140219185949.GA1179@order.stressinduktion.org> <20140219191831.GA7119@breakpoint.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:39057 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754604AbaBSTaj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Feb 2014 14:30:39 -0500
Content-Disposition: inline
In-Reply-To: <20140219191831.GA7119@breakpoint.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 19, 2014 at 08:18:31PM +0100, Florian Westphal wrote:
> Hannes Frederic Sowa <hannes@stressinduktion.org> wrote:
> > On Wed, Feb 19, 2014 at 10:49:47AM -0800, Eric Dumazet wrote:
> > > On Wed, 2014-02-19 at 13:17 -0500, David Miller wrote:
> > > > From: Florian Westphal <fw@strlen.de>
> > > > Date: Mon, 17 Feb 2014 22:57:48 +0100
> > > > 
> > > > > Three counters are added:
> > > > > - one to track when we went from non-zero to zero window
> > > > > - one to track the reverse
> > > > > - one counter incremented when we want to announce zero window.
> > > > > 
> > > > > The latter is added because it can show cases where we want to close the
> > > > > window but can't because we would shrink window.
> > > > > 
> > > > > Suggested-by: Eric Dumazet <edumazet@google.com>
> > > > > Signed-off-by: Florian Westphal <fw@strlen.de>
> > > > > ---
> > > > >  Eric, is this what you had in mind?
> > > > > 
> > > > >  I re-ran my 'slow-sender-with-reader-that-does-not-drain-socket'
> > > > >  scenario and, as expected, only TCPWANTZEROWINDOW increases.
> > > > 
> > > > Eric, ping?
> > > 
> > > Thanks, I missed this patch. Let me think about it, thanks !
> > 
> > We need NET_INC_STATS instead of NET_INC_STATS_BH, no?
> 
> sure, I can send v2 but I'll wait for (n)ack from Eric first
> before considering it.
> 
> tcp_transmit_skb (caller of tcp_select_window) also uses _BH
> which is why it ended up in tcp_select_window.

NET_STATS only use 32 bit counter and thus need not be protected with a
seqlock on 32 bit platforms. As such, it does not matter, but e.g. the IP
counter are prone to deadlocks if used with wrong postfix because of 64 bit
counter thus protected by seqlock.

A pitty that the _STATS_BH postfixes have the opposite meaning of the bottom
_bh postfixes.

Basically always safe is _STATS and if we are sure we can omit the bh disable
call because we only call the function from bh, we can use _STATS_BH calls.

Greetings,

  Hannnes
