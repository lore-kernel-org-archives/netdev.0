From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: high latency with TCP connections
Date: Fri, 1 Sep 2006 01:46:35 +0400
Message-ID: <20060831214635.GA2680@ms2.inr.ac.ru>
References: <20060830100734.GA22235@isil.ipib.msu.ru> <20060830102727.11e11453@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Alexander Vodomerov <alex@sectorb.msk.ru>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:64401 "HELO ms2.inr.ac.ru")
	by vger.kernel.org with SMTP id S932452AbWHaVra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 31 Aug 2006 17:47:30 -0400
To: Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20060830102727.11e11453@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> Expecting any performance with one byte write's is silly.

I am not sure why you are so confident about status of ABC.
I missed the discussions, when it was implemented. Apparently,
it was noticed that ABC in its pure form does not make sense
with snd_cwnd counted in packets and there were some reasons,
why it still was not adapted.

That's what I am sure: if congestion control causes delack syndrome,
it is difficult to advocate this congestion control scheme.
It must be repaired, if there is even the smallest possibility
to do this.


The first idea:

Behaviour is broken, when we have < 2*MSS in flight. In that
case receiver falls to delack timeout and breaks ACK clock.

	thresh = tp->mss_cache;

	if (tp->snd_nxt - tp->snd_una <= tp->mss_cache) {
		thresh = 1;
		if (tp->send_head)
			thresh = tp->send_head->len;
		/* If send_head is empty, it disables ABC.
		 * If send_head is good mss sized segment, ABC is in work.
		 * If send_head is a small segment, it is half-way.
		 */
	}

	if (tp->bytes_acked < thresh)
	       return;

Probably, do this only when TCP_NODELAY is set, but actually it does not
matter. If it is nagled/corked, cwnd will not be used/increased in any case.





