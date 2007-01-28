From: Baruch Even <baruch@ev-en.org>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Sun, 28 Jan 2007 07:27:04 +0200
Message-ID: <20070128052704.GH22455@galon.ev-en.org>
References: <20070127164702.GA4829@galon.ev-en.org> <20070127164949.GC4829@galon.ev-en.org> <20070127.200609.35666070.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rrcs-24-123-59-149.central.biz.rr.com ([24.123.59.149]:58431
	"EHLO galon.ev-en.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932261AbXA1F1I (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Jan 2007 00:27:08 -0500
Content-Disposition: inline
In-Reply-To: <20070127.200609.35666070.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* David Miller <davem@davemloft.net> [070128 06:06]:
> From: Baruch Even <baruch@ev-en.org>
> Date: Sat, 27 Jan 2007 18:49:49 +0200
> 
> > Since the SACK receive cache doesn't need the data to be in host
> > order we also remove the ntohl in the checking loop.
>  ...
> > -	for (i = 0; i< num_sacks; i++) {
> > -		__u32 start_seq = ntohl(sp[i].start_seq);
> > -		__u32 end_seq =	 ntohl(sp[i].end_seq);
> > +	for (i = 0; i < num_sacks; i++) {
> > +		__u32 start_seq = sp[i].start_seq;
> > +		__u32 end_seq = sp[i].end_seq;
>  ...
> >  		}
> >  		tp->recv_sack_cache[i].start_seq = start_seq;
> >  		tp->recv_sack_cache[i].end_seq = end_seq;
> 
> Ok, and now the sack cache and the real sack blocks are
> stored in net-endian and this works out because we only
> make direct equality comparisons with the recv_sack_cache[]
> entry values?

Yes. The only comparison we do with recv_sack_cache entries is != and
that works for net-endian just fine.

The only reason recv_sack_cache was in host-order before that was that
start_seq and end_seq were used to do more before/after comparisons for
DSACK.

Baruch
