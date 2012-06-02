From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Sat, 02 Jun 2012 07:46:32 +0200
Message-ID: <1338615992.2760.1665.camel@edumazet-glaptop>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
	 <CAA93jw755V9kJ=P1gFsG2oafddhsebzfT3DuY5NX59GPpheOZg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:63074 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933187Ab2FBFqh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 01:46:37 -0400
Received: by wgbdr13 with SMTP id dr13so2509975wgb.1
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 22:46:36 -0700 (PDT)
In-Reply-To: <CAA93jw755V9kJ=P1gFsG2oafddhsebzfT3DuY5NX59GPpheOZg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-06-01 at 18:28 -0700, Dave Taht wrote:
> On Thu, May 31, 2012 at 2:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > pfifo_fast being the default Qdisc, its pretty easy to fill it with
> > SYNACK (small) packets while host is under SYNFLOOD attack.
> >
> > Packets of established TCP sessions are dropped and host appears almost
> > dead.
> >
> > Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
> > generated in SYNCOOKIE mode, so that these packets are enqueued into
> > pfifo_fast band 2.
> >
> > Other packets, queued to band 0 or 1 are dequeued before any SYNACK
> > packets waiting in band 2.
> 
> I am curious as to how well fq_codel survives an attack like this, without aid.

codel or fq_codel are not doing priority classification.

SYNACK will spread in all hash buckets and global queue limit can be
hit.

fq_codel wont protect you by itself, unless you use a hierarchy with one
"prio" and two or three "fq_codel".
