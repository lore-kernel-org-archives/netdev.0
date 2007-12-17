From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: Re: [PATCH 2/2] [TCP]: Include __tcp_reset_fack_counts to non-__
 version
Date: Mon, 17 Dec 2007 13:38:30 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0712171234160.20530@kivilampi-30.cs.helsinki.fi>
References: <11973738391620-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11973738393633-git-send-email-ilpo.jarvinen@helsinki.fi>
 <11973738392955-git-send-email-ilpo.jarvinen@helsinki.fi>
 <20071211151336.GA1248@infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, Netdev <netdev@vger.kernel.org>
To: Christoph Hellwig <hch@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:58131 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765179AbXLQLic (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Dec 2007 06:38:32 -0500
In-Reply-To: <20071211151336.GA1248@infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 11 Dec 2007, Christoph Hellwig wrote:

> On Tue, Dec 11, 2007 at 01:50:39PM +0200, Ilpo J?rvinen wrote:
> > +		BUG_ON((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]));
> > +
> > +		tcp_for_write_queue_from(skb[queue], sk, queue) {
> > +			if ((prev != NULL) && !tcp_skb_adjacent(sk, prev, skb[queue]))
> > +				break;
> > +
> > +			if (!before(TCP_SKB_CB(skb[queue])->seq, tcp_sk(sk)->snd_nxt) ||
> > +			    TCP_SKB_CB(skb[queue])->fack_count == fc)
> > +				return;
> 
> There's quite a few overflows of the normal 80 char limit here.  Because
> you're current style is a little on the verbose side that's trivially
> fixable, though:

This part got removed when part of TCP code got removed during net-2.6.25 
rebase...

Thanks anyway for the reminder, I'll try to be more careful during code 
moves in future but I'll probably continue to allow expections in cases 
where the offenders only consist of closing parenthesis, block opening 
brace and termination semicolon (like it was in one of these lines as 
well).

-- 
 i.
