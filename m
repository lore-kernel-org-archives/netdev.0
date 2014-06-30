From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Mon, 30 Jun 2014 01:15:19 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1406300112340.31629@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>   <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>   <alpine.DEB.2.02.1406101726390.11647@dtop>   <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>  <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1406281724370.18954@dtop> <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Alexey Preobrazhensky <preobr@google.com>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	David Miller <davem@davemloft.net>, paulmck@linux.vnet.ibm.com,
	netdev@vger.kernel.org, Kostya Serebryany <kcc@google.com>,
	Dmitry Vyukov <dvyukov@google.com>,
	Lars Bull <larsbull@google.com>,
	Eric Dumazet <edumazet@google.com>,
	Bruce Curtis <brutus@google.com>,
	=?ISO-8859-2?Q?Maciej_=AFenczykowski?= <maze@google.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from li263-96.members.linode.com ([173.255.253.96]:55459 "EHLO
	mail.rydia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752209AbaF3IXq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Jun 2014 04:23:46 -0400
In-Reply-To: <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 29 Jun 2014, Eric Dumazet wrote:

> On Sat, 2014-06-28 at 17:25 -0700, dormando wrote:
> > On Tue, 10 Jun 2014, Eric Dumazet wrote:
> >
> > > On Tue, 2014-06-10 at 18:12 -0700, Eric Dumazet wrote:
> > >
> > > >
> > > > For the curious, another problem is in ipv4_sk_update_pmtu()
> > > >
> > > > This can be called on UDP sockets, but from softirq context.
> > > >
> > > > We cannot use sk_dst_lock because this lock is not softirq safe.
> > > >
> > > > I guess we should use xchg() for sk_dst_set() and sk_dst_reset()
> > >
> > > This would be something like this untested patch :
> > >
> >
> > I see this didn't get queued for stable, should it be dropped due to the
> > later patch? (which did get queued for stable).
>
> I have this patch in my queue.
>
> I have to submit it officially before it can be merged...
>
> David seems quite busy these days anyway.
>

Heh. You folks have quite insane amounts of output.

I'm now testing a kernel which has the one upstreamed patch + the two not
yet in -stable, under 3.10.45. A kernel with ~60% of those patches has
been running for 17.5 days so far. Much longer than it normally runs.

So, looking pretty decent, still. Thanks for your patience for all of my
dumb questions. I'll probably only pipe up again on this issue if I see
another crash.
