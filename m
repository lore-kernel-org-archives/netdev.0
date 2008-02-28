From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 3/4] [CCID2]: Replace broken RTT estimator with better algorithm
Date: Thu, 28 Feb 2008 09:53:33 +0000
Message-ID: <20080228095333.GA4730@gerrit.erg.abdn.ac.uk>
References: <1204122188-9984-1-git-send-email-gerrit@erg.abdn.ac.uk> <1204122188-9984-2-git-send-email-gerrit@erg.abdn.ac.uk> <1204122188-9984-3-git-send-email-gerrit@erg.abdn.ac.uk> <1204122188-9984-4-git-send-email-gerrit@erg.abdn.ac.uk> <5bc4c4570802271840t2b3b12a1k260d1e2d7440bdb2@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: acme@redhat.com, dccp@vger.kernel.org, netdev@vger.kernel.org
To: Leandro Sales <leandroal@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:33848 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751597AbYB1Jyl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Feb 2008 04:54:41 -0500
Content-Disposition: inline
In-Reply-To: <5bc4c4570802271840t2b3b12a1k260d1e2d7440bdb2@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| >  +                * Decay RTTVAR at most once per flight, exploiting that
| >  +                *  1) pipe <= cwnd <= Sequence_Window = W  (RFC 4340, 7.5.2)
| >  +                *  2) AWL = GSS-W+1 <= GAR <= GSS          (RFC 4340, 7.5.1)
| >  +                * GAR is a useful bound for FlightSize = pipe, AWL is probably
| >  +                * too low as it over-estimates pipe.
| >  +                */
| >  +               if (after48(dccp_sk(sk)->dccps_gar, hctx->ccid2hctx_rtt_seq)) {
| >  +                       if (hctx->ccid2hctx_mdev_max < hctx->ccid2hctx_rttvar)
| >  +                               hctx->ccid2hctx_rttvar -= (hctx->ccid2hctx_rttvar - hctx->ccid2hctx_mdev_max) >> 2;
| 
| More than 80 chars in this line! 87 chars. Is this ok?
| 
There are actually 120 characters in this line. The 80-characters constraint
has become a recommendation, i.e. it is possible and legal to make exceptions.
I kept it in to allow a better comparison to the original TCP code.

If anything, it shows how the ubiquitous `hctx->ccid?hctx_' prefixes make
it hard to read the code.
