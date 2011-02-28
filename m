From: Tom Herbert <therbert@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Sun, 27 Feb 2011 19:45:55 -0800
Message-ID: <AANLkTinxv4JC20YepcMvWi8SL_VTX2sXcRMydD62TT6x@mail.gmail.com>
References: <20110225.112019.48513284.davem@davemloft.net>
	<20110226005718.GA19889@gondor.apana.org.au>
	<20110227110205.GE9763@canuck.infradead.org>
	<20110227110614.GA6246@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:49461 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752367Ab1B1Dp7 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 Feb 2011 22:45:59 -0500
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p1S3jwgZ001572
	for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 19:45:58 -0800
Received: from pzk5 (pzk5.prod.google.com [10.243.19.133])
	by wpaz29.hot.corp.google.com with ESMTP id p1S3ju7o027819
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 19:45:57 -0800
Received: by pzk5 with SMTP id 5so843505pzk.37
        for <netdev@vger.kernel.org>; Sun, 27 Feb 2011 19:45:56 -0800 (PST)
In-Reply-To: <20110227110614.GA6246@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I disagree completely.
>
> This patch adds a user-space API that we will have to carry
> with us for perpetuity. =A0I would only support this if we had
> no other way around the problem.
>
> If this does turn out to be mostly due to sendmsg contention
> then fixing it is going to be much simpler than making the UDP
> stack multiqueue capable.
>

That sounds promising, but receive side will still have problems.
There is lock contention on the queue as well as cache line bouncing
on the sock structures.  Also multiple threads sleeping on same socket
typically leads to asymmetric load across the threads (and
degenerative cases where receiving thread is woken up and other
threads have already processed all the packets).  TCP listener threads
suffer from these same problems.

Tom


> I'm working on this right now.
>
> Cheers,
> --
> Email: Herbert Xu <herbert@gondor.apana.org.au>
> Home Page: http://gondor.apana.org.au/~herbert/
> PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
>
