From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: [PATCH] pkt_sched: Destroy gen estimators under rtnl_lock().
Date: Tue, 26 Aug 2008 22:41:53 +1000
Message-ID: <20080826124153.GA2732@gondor.apana.org.au>
References: <20080822120918.GB14981@ff.dom.local> <20080822121144.GA32397@gondor.apana.org.au> <20080822.051841.259820995.davem@davemloft.net> <20080822124556.GA15788@gondor.apana.org.au> <20080824192639.587f9391@speedy> <20080824234947.GA19018@gondor.apana.org.au> <20080824202922.2cc9b9f6@speedy> <20080826073508.GA1039@gondor.apana.org.au> <20080826074702.GA1102@gondor.apana.org.au> <20080826082455.729662ae@speedy>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, jarkao2@gmail.com,
	netdev@vger.kernel.org, denys@visp.net.lb,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	jamal <hadi@cyberus.ca>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:56480 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754641AbYHZMmE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2008 08:42:04 -0400
Content-Disposition: inline
In-Reply-To: <20080826082455.729662ae@speedy>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

(Adding Jamal to the cc)

On Tue, Aug 26, 2008 at 08:24:55AM -0400, Stephen Hemminger wrote:
> 
> The problem with netem as child of TBF is that TBF counts the number
> of packets in the queue to determine the rate. Therefore TBF gets confused
> about the rate because of the large number of packets that are held in
> netem when delaying. 

OK I'm probably missing something.  I can't find any code in TBF
that looks at the number of packets held in the queue.  All it
does is look at the dequeued packet and whether we have enough
tokens to send it right now.

In any case, looking at the number of packets in the queue sounds
broken for TBF as the packets could be held in upper-level queues
which are invisible.

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
