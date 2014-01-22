From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH 1/1] Per socket value for max datagram queue length
Date: Wed, 22 Jan 2014 16:32:35 +0100
Message-ID: <20140122153235.GC7269@order.stressinduktion.org>
References: <13e8aad86903481261581de7c29444e3@mindstab.net> <20140122152036.GB7269@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Dan Ballard <dan@mindstab.net>,
	Lennart Poettering <lennart@poettering.net>,
	kay.sievers@vrfy.org, Arnd Bergmann <arnd@arndb.de>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Eliezer Tamir <eliezer.tamir@linux.intel.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Li Zefan <lizefan@huawei.com>, linux-arch@vger.kernel.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:58094 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756012AbaAVPcg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 10:32:36 -0500
Content-Disposition: inline
In-Reply-To: <20140122152036.GB7269@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 22, 2014 at 04:20:36PM +0100, Hannes Frederic Sowa wrote:
> On Wed, Jan 22, 2014 at 07:11:20AM -0800, Dan Ballard wrote:
> > diff --git a/net/core/sock.c b/net/core/sock.c
> > index 5393b4b..1ff69d1 100644
> > --- a/net/core/sock.c
> > +++ b/net/core/sock.c
> > @@ -915,6 +915,10 @@ set_rcvbuf:
> >                                          sk->sk_max_pacing_rate);
> >                 break;
> > 
> > +       case SO_MAX_DGRAM_QLEN:
> > +               sk->sk_max_ack_backlog = val;
> > +               break;
> > +
> 
> Shouldn't the backlog be capped for unprivileged users to some configurable
> value? I even think that max_dgram_qlen should be the upper bound.
> 
> I guess it is not that serious as socket read accounting does account all
> packets which sit in the backlog queue.

Just a follow-up:

sk_max_ack_backlog is also responsible for limiting the af_unix
dgram queues.  Currently there is no socket accounting for the read
side of those unix dgram sockets. I tried to fix this once here,
http://patchwork.ozlabs.org/patch/231032/, but until that is done we
depend on max_dgram_qlen to limit those queues at all.

I hope I can get back to this patch anytime soon, as it solves the problem
that a bidirectional protocol ping-ponging with a dgram server socket
and not fetching its messages from the backlog queue can bring a server
to halt because it doesn't have any send space on the socket anymore.

Greetings,

  Hannes
