From: Dave Taht <dave.taht@gmail.com>
Subject: Re: [PATCH net-next] tcp: avoid tx starvation by SYNACK packets
Date: Fri, 1 Jun 2012 18:28:17 -0700
Message-ID: <CAA93jw755V9kJ=P1gFsG2oafddhsebzfT3DuY5NX59GPpheOZg@mail.gmail.com>
References: <1338501397.2760.1395.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Hans Schillstrom <hans.schillstrom@ericsson.com>,
	netdev <netdev@vger.kernel.org>,
	Neal Cardwell <ncardwell@google.com>,
	Tom Herbert <therbert@google.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:49706 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S966150Ab2FBB2U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 21:28:20 -0400
Received: by weyu7 with SMTP id u7so1723130wey.19
        for <netdev@vger.kernel.org>; Fri, 01 Jun 2012 18:28:19 -0700 (PDT)
In-Reply-To: <1338501397.2760.1395.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 31, 2012 at 2:56 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> From: Eric Dumazet <edumazet@google.com>
>
> pfifo_fast being the default Qdisc, its pretty easy to fill it with
> SYNACK (small) packets while host is under SYNFLOOD attack.
>
> Packets of established TCP sessions are dropped and host appears almost
> dead.
>
> Avoid this problem assigning TC_PRIO_FILLER priority to SYNACK
> generated in SYNCOOKIE mode, so that these packets are enqueued into
> pfifo_fast band 2.
>
> Other packets, queued to band 0 or 1 are dequeued before any SYNACK
> packets waiting in band 2.

I am curious as to how well fq_codel survives an attack like this, without aid.
