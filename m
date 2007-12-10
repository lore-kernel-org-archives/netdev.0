From: Arnaldo Carvalho de Melo <acme@redhat.com>
Subject: Re: [PATCH 5/8] [TFRC]: Loss interval code needs the
	macros/inlines that were moved
Date: Mon, 10 Dec 2007 09:48:08 -0200
Message-ID: <20071210114807.GC13179@ghostprotocols.net>
References: <11971083882331-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881862-git-send-email-gerrit@erg.abdn.ac.uk> <11971083881667-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883685-git-send-email-gerrit@erg.abdn.ac.uk> <1197108388630-git-send-email-gerrit@erg.abdn.ac.uk> <11971083883727-git-send-email-gerrit@erg.abdn.ac.uk> <20071208184711.GF3180@ghostprotocols.net> <20071210113153.GB4688@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>, dccp@vger.kernel.org,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:43250 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756745AbXLJLsP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 10 Dec 2007 06:48:15 -0500
Content-Disposition: inline
In-Reply-To: <20071210113153.GB4688@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Em Mon, Dec 10, 2007 at 11:31:53AM +0000, Gerrit Renker escreveu:
> | > 
> | >   distcc[24516] ERROR: compile /root/.ccache/packet_his.tmp.aspire.home.net.24512.i on _tiptop failed
> | >   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c: In function '__one_after_loss':
> | >   /usr/src/davem-2.6/net/dccp/ccids/lib/packet_history.c:266: error: lvalue required as unary '&' operand
> <snip>
> | 
> | Because you do it this way:
> | 
> | tfrc_rx_hist_swap(&TFRC_RX_HIST_ENTRY(h, 0), &TFRC_RX_HIST_ENTRY(h, 3));
> | 
> | I checked and at least in this patch series all uses are of this type,
> | so why not do it using just the indexes, which would be simpler:
> | 
> | tfrc_rx_hist_swap(h, 0, 3);
> | 
> | With this implementation:
> | 
> | static void tfrc_rx_hist_swap(struct tfrc_rx_hist *h, const int a, const int b)
> | {
> | 	const int idx_a = tfrc_rx_hist_index(h, a),
> | 	      int idx_b = tfrc_rx_hist_index(h, b);
> | 	struct tfrc_rx_hist_entry *tmp = h->ring[idx_a];
> | 
> | 	h->ring[idx_a] = h->ring[idx_b];
> | 	h->ring[idx_b] = tmp;
> | }
> | 
> Agreed, that is useful in the present case, since then everything uses
> inlines. The only suggestion I'd like to make is to use `u8' instead of 
> `int' since the indices will have very low values.

Agreed.
 
> There is a related point: you will probably have noticed that loss_interval.c 
> also uses macros. I don't know if you are planning to convert these also into 
> inlines. I think that there would be less benefit in converting these, since
> they are locl to loss_interval.c and mostly serve to improve readability.

In general I'm against using macros for functions, so please always
consider doing things as inlines.

I'll read some more patches today and provide comments as to if I think
it is ok for now to keep it as macros.

> As I have at least one other patch to revise (plus another minor one),
> I'll rework this according to the above. 

Thank you.

- Arnaldo
