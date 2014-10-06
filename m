From: David Miller <davem@davemloft.net>
Subject: Re: bridge: Do not compile options in br_parse_ip_options
Date: Mon, 06 Oct 2014 00:53:25 -0400 (EDT)
Message-ID: <20141006.005325.565105939884937203.davem@davemloft.net>
References: <20141004100413.GA1241@breakpoint.cc>
	<20141004135508.GA10705@gondor.apana.org.au>
	<20141004141802.GA10878@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: fw@strlen.de, netfilter-devel@vger.kernel.org, bsd@redhat.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com, davidn@davidnewall.com
To: herbert@gondor.apana.org.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:57839 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752258AbaJFEx2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 00:53:28 -0400
In-Reply-To: <20141004141802.GA10878@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Herbert Xu <herbert@gondor.apana.org.au>
Date: Sat, 4 Oct 2014 22:18:02 +0800

> bridge: Do not compile options in br_parse_ip_options
> 
> Commit 462fb2af9788a82a534f8184abfde31574e1cfa0
> 
> 	bridge : Sanitize skb before it enters the IP stack
> 
> broke when IP options are actually used because it mangles the
> skb as if it entered the IP stack which is wrong because the
> bridge is supposed to operate below the IP stack.
> 
> Since nobody has actually requested for parsing of IP options
> this patch fixes it by simply reverting to the previous approach
> of ignoring all IP options, i.e., zeroing the IPCB.
> 
> If and when somebody who uses IP options and actually needs them
> to be parsed by the bridge complains then we can revisit this.
> 
> Reported-by: David Newall <davidn@davidnewall.com>
> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

Agreed that mangling the packet is definitely wrong here, and since
you preserve the CB clearing this change should be fine.

Please submit this formally after it's been tested.

Thanks.
