From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Tue, 24 Apr 2012 04:13:31 +0200
Message-ID: <1335233611.5205.90.camel@edumazet-glaptop>
References: <1335201102.5205.28.camel@edumazet-glaptop>
	 <CADVnQyngwym7z_zSi8h2U_1e_wVCwGMPZScywWFWM2AYvxyqjw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:64363 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756235Ab2DXCNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:13:35 -0400
Received: by wejx9 with SMTP id x9so96915wej.19
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:13:34 -0700 (PDT)
In-Reply-To: <CADVnQyngwym7z_zSi8h2U_1e_wVCwGMPZScywWFWM2AYvxyqjw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-04-23 at 21:13 -0400, Neal Cardwell wrote:
> On Mon, Apr 23, 2012 at 1:11 PM, Eric Dumazet <eric.dumazet@gmail.com> wrote:
> > From: Eric Dumazet <edumazet@google.com>
> >
> > commit c8628155ece3 (tcp: reduce out_of_order memory use) took care of
> > coalescing tcp segments provided by legacy devices (linear skbs)
> >
> > We extend this idea to fragged skbs, as their truesize can be heavy.
> >
> > ixgbe for example uses 256+1024+PAGE_SIZE/2 = 3328 bytes per segment.
> >
> > Use this coalescing strategy for receive queue too.
> >
> > This contributes to reduce number of tcp collapses, at minimal cost, and
> > reduces memory overhead and packets drops.
> 
> The mechanics look solid, but I'm a little concerned about the
> potential added overhead for the new case where tcp_try_coalesce()
> does a skb_copy_bits() for in-order data that it is coalescing at the
> end of the sk_receive_queue. Do you have any performance numbers for
> this case to help suggest whether this added copy is a concern?
> 
> neal

This never happens on connections where performance matters : skb head
can only contains one full mss segment.

This part is only used on wifi devices, where skb head is really fat.
