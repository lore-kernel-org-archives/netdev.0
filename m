From: dormando <dormando@rydia.net>
Subject: Re: [PATCH] ipv4: fix a race in ip4_datagram_release_cb()
Date: Tue, 8 Jul 2014 00:01:01 -0700 (PDT)
Message-ID: <alpine.DEB.2.02.1407072357320.7769@dtop>
References: <CA+FTKhs45vD66xSQRgijwFjSuy-Mt8EGr3cRv60oCcEnFPKnaQ@mail.gmail.com>     <1402407781.3645.426.camel@edumazet-glaptop2.roam.corp.google.com>     <alpine.DEB.2.02.1406101726390.11647@dtop>     <1402448128.3645.437.camel@edumazet-glaptop2.roam.corp.google.com>
  <1402449173.3645.440.camel@edumazet-glaptop2.roam.corp.google.com>    <1402450009.3645.444.camel@edumazet-glaptop2.roam.corp.google.com>    <alpine.DEB.2.02.1406281724370.18954@dtop>   <1404110292.15139.42.camel@edumazet-glaptop2.roam.corp.google.com>  
 <alpine.DEB.2.02.1406300112340.31629@dtop>  <1404117049.15139.63.camel@edumazet-glaptop2.roam.corp.google.com>  <alpine.DEB.2.02.1407071834230.586@dtop> <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
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
Received: from li263-96.members.linode.com ([173.255.253.96]:56549 "EHLO
	mail.rydia.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752670AbaGHHBG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jul 2014 03:01:06 -0400
In-Reply-To: <1404802064.3515.4.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 8 Jul 2014, Eric Dumazet wrote:

> On Mon, 2014-07-07 at 18:41 -0700, dormando wrote:
>
> > Mostly there, but I think we hit what might be a new bug.. The machines
> > which crashed every few days previously have been stable for weeks.
> >
> > however I had one machine running the new kernel in a larger cluster
> > elsewhere; we had a network event and the one machine on the new kernel
> > panic'ed in ipv4_dst_destroy, but what looks like a new path. Sadly I've
> > had to halt the rollout :( All of the older unfixed kernels survived this
> > particular network event.
> >
> > Unfortunately this is still on 3.10, due to a bad softirq regression in
> > 3.14 I've not had time to track down. I applied all of your patches for
> > what wasn't already in 3.10. The only other change I made was to un-revert
> > 62713c4b6bc10c2d082ee1540e11b01a2b2162ab - which I'd been keeping reverted
> > as it was making crashes much more frequent.
>
> Hmm, always give patch title or a valid sha1 commit, this one is not in
> David trees, so its hard to tell.
>

Damn, sorry. I thought it was valid:
Author: Alexei Starovoitov <ast@plumgrid.com>
Date:   Tue Nov 19 19:12:34 2013 -0800

    ipv4: fix race in concurrent ip_route_input_slow()

    [ Upstream commit dcdfdf56b4a6c9437fc37dbc9cee94a788f9b0c4 ]

It's a thing that uses a DST_NOCACHE flag. I can re-add the reversion to
my own tree, but it should probably be reviewed again I guess?

We had another thread about it a while ago. I'd upgraded between stable
revisions of 3.10 (when this patch was added) and machines in one
datacenter started crashing every few hours. Thread never went anywhere.

Tried removing the reversion since your recent patches should've fixed the
underlying problem.

I have no idea if this patch is the problem or not though, just adding the
information for completeness. We had no luck at all reproducing this
latest crash.
