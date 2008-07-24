From: Willy Tarreau <w@1wt.eu>
Subject: Re: [TCP bug, regression] stuck distcc connections in latest -git
Date: Thu, 24 Jul 2008 10:24:53 +0200
Message-ID: <20080724082453.GA17917@1wt.eu>
References: <20080724063242.GA9051@elte.hu> <E1KLvds-0001Mc-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, davem@davemloft.net,
	davidn@davidnewall.com, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, stefanr@s5r6.in-berlin.de,
	rjw@sisk.pl
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 1wt.eu ([62.212.114.60]:1949 "EHLO 1wt.eu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751307AbYGXI0I (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 24 Jul 2008 04:26:08 -0400
Content-Disposition: inline
In-Reply-To: <E1KLvds-0001Mc-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jul 24, 2008 at 03:53:40PM +0800, Herbert Xu wrote:
> Ingo Molnar <mingo@elte.hu> wrote:
> > 
> > here's a longer log from the server, with sequences, flags, etc:
> 
> Sorry but which is the server, phoenix?
> 
> > 08:28:48.029057 IP (tos 0x0, ttl 64, id 27412, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x8316 (correct), 2272574194:2272574194(0) ack 234561256 win 65535
> > 08:30:48.049167 IP (tos 0x0, ttl 64, id 14022, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234561256:234561792(536) ack 2272574194 win 5840
> > 08:30:48.049223 IP (tos 0x0, ttl 64, id 27413, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> > 08:30:48.049341 IP (tos 0x0, ttl 64, id 14023, offset 0, flags [DF], proto TCP (6), length 576) dione.39201 > phoenix.distcc: . 234626648:234627184(536) ack 2272574194 win 5840
> > 08:30:48.049348 IP (tos 0x0, ttl 64, id 14024, offset 0, flags [DF], proto TCP (6), length 183) dione.39201 > phoenix.distcc: . 234627184:234627327(143) ack 2272574194 win 5840
> > 08:30:48.049354 IP (tos 0x0, ttl 64, id 27414, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> > 08:30:48.049359 IP (tos 0x0, ttl 64, id 27415, offset 0, flags [DF], proto TCP (6), length 40) phoenix.distcc > dione.39201: ., cksum 0x80fe (correct), 2272574194:2272574194(0) ack 234561792 win 65535
> 
> No further traffic is generated for this connection?
> 
> For a problem like this, you really need to dump on both sides
> to get the full picture.  Otherwise it's difficult to tell why
> we have a gap after 234561792 which is never filled in by dione.

Given the TTLs, it looks to me like both are on the same LAN. Also,
234561792 is the window trail it seems.

> BTW any reason why you appear to have SACK off?

and also MSS is at the lowest value (536), maybe because of numerous
losses on large segments ?

Willy

