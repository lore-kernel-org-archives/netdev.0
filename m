From: Christoph Paasch <christoph.paasch@uclouvain.be>
Subject: Re: [PATCH 0/4] Make tcp-metrics source-address aware
Date: Mon, 16 Dec 2013 21:01:15 +0100
Message-ID: <20131216200115.GA15318@cpaasch-mac>
References: <1387109444-1104-1-git-send-email-christoph.paasch@uclouvain.be>
 <1387132859.19078.207.camel@edumazet-glaptop2.roam.corp.google.com>
 <CAK6E8=eeH=6daXoX9Dwe3Nj5LEhKBfL=-2FaLd=Jo7WM-q34qw@mail.gmail.com>
 <20131216193041.GA16966@cpaasch-mac>
 <CAK6E8=e4aQ2qqZ4uBNZBvyYdQ1KER8xashQVAYJoiEUm9sbSew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Julian Anastasov <ja@ssi.bg>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.sgsi.ucl.ac.be ([130.104.5.67]:46249 "EHLO
	smtp5.sgsi.ucl.ac.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750869Ab3LPUBW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Dec 2013 15:01:22 -0500
Content-Disposition: inline
In-Reply-To: <CAK6E8=e4aQ2qqZ4uBNZBvyYdQ1KER8xashQVAYJoiEUm9sbSew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16/12/13 - 11:53:31, Yuchung Cheng wrote:
> > Agreed, in this case it would be negative. Although I doubt that it happens
> > often that the source changes while the public IP remains the same.
> >
> > But for the WiFi/3G-case it is really bad that parameters like
> > ssthresh/rtt/... are kept the same. We will exit slow-start too early when
> > going from WiFi to 3G because ssthresh is too low.
> >
> > What if we copy the fast-open cookie across the different src/dst tcp_metrics-pairs
> > to handle Yuchung's case?
> > Or, maybe get rid of ssthresh/rtt/... in tcp-metrics? But that would probably be too
> > agressive...
> +1 to get rid of ssthresh caching. It often hurts than helps and
> cubic-hystart already mitigates the SS overshoot. See sec 6.2.4 in a
> recent research study
> http://conferences.sigcomm.org/co-next/2013/program/p303.pdf

I haven't yet read the paper, but in their presentation at CoNEXT they said
that the biggest impact comes from spurious retransmission timeouts and the
subsequent cwnd reduction. I would have thought that the cwnd-reduction
undo-procedure covers this case.

> The only case caching RTT could help is the init RTO. But it's unclear
> adding src-ip along will help like DM said.
> 
> Another metric that may have negative effect is reordering metrics.

So, let's get rid of all these metrics (except for TFO)? ;)


Christoph
