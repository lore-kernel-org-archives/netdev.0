From: Christoph Hellwig <hch@infradead.org>
Subject: Re: [PATCH 2/2] [TCP]: Include __tcp_reset_fack_counts to non-__
	version
Date: Tue, 11 Dec 2007 15:13:36 +0000
Message-ID: <20071211151336.GA1248@infradead.org>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi> <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi> <11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ilpo J?rvinen <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:45214 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbXLKPNm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Dec 2007 10:13:42 -0500
Content-Disposition: inline
In-Reply-To: <11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 11, 2007 at 01:50:39PM +0200, Ilpo J?rvinen wrote:
> +		BUG_ON((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]));
> +
> +		tcp_for_write_queue_from(skb[queue], sk, queue) {
> +			if ((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]))
> +				break;
> +
> +			if (!before(TCP_SKB_CB(skb[queue])->seq, tcp_sk(sk)->snd_nxt) ||
> +			    TCP_SKB_CB(skb[queue])->fack_count == fc)
> +				return;

There's quite a few overflows of the normal 80 char limit here.  Because
you're current style is a little on the verbose side that's trivially
fixable, though:

		BUG_ON(prev && !tcp_skb_adjacent(sk, prev, skb[queue]));

		tcp_for_write_queue_from(skb[queue], sk, queue) {
			if (prev && !tcp_skb_adjacent(sk, prev, skb[queue]))
				break;

			if (!before(TCP_SKB_CB(skb[queue])->seq,
					       tcp_sk(sk)->snd_nxt) ||
			    TCP_SKB_CB(skb[queue])->fack_count == fc)
				return;

