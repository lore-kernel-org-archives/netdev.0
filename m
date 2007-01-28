From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/3] Seperate DSACK from SACK fast path
Date: Sat, 27 Jan 2007 20:06:09 -0800 (PST)
Message-ID: <20070127.200609.35666070.davem@davemloft.net>
References: <20070127164702.GA4829@galon.ev-en.org>
	<20070127164949.GC4829@galon.ev-en.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: baruch@ev-en.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50529
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751838AbXA1EGL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jan 2007 23:06:11 -0500
In-Reply-To: <20070127164949.GC4829@galon.ev-en.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Baruch Even <baruch@ev-en.org>
Date: Sat, 27 Jan 2007 18:49:49 +0200

> Since the SACK receive cache doesn't need the data to be in host
> order we also remove the ntohl in the checking loop.
 ...
> -	for (i = 0; i< num_sacks; i++) {
> -		__u32 start_seq = ntohl(sp[i].start_seq);
> -		__u32 end_seq =	 ntohl(sp[i].end_seq);
> +	for (i = 0; i < num_sacks; i++) {
> +		__u32 start_seq = sp[i].start_seq;
> +		__u32 end_seq = sp[i].end_seq;
 ...
>  		}
>  		tp->recv_sack_cache[i].start_seq = start_seq;
>  		tp->recv_sack_cache[i].end_seq = end_seq;

Ok, and now the sack cache and the real sack blocks are
stored in net-endian and this works out because we only
make direct equality comparisons with the recv_sack_cache[]
entry values?
