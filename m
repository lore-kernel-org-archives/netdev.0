From: Tom Herbert <therbert@google.com>
Subject: Re: SO_REUSEPORT - can it be done in kernel?
Date: Tue, 1 Mar 2011 23:12:29 -0800
Message-ID: <AANLkTim0+7mTYrQF3mttUW+JqOmvTyMoDXOdeCX_SSdp@mail.gmail.com>
References: <20110301110708.GJ9763@canuck.infradead.org>
	<1298977984.3284.15.camel@edumazet-laptop>
	<20110301112759.GK9763@canuck.infradead.org>
	<1298979909.3284.28.camel@edumazet-laptop>
	<20110301115305.GA6984@gondor.apana.org.au>
	<1298984609.3284.98.camel@edumazet-laptop>
	<20110301131823.GB8028@gondor.apana.org.au>
	<1298997084.3284.119.camel@edumazet-laptop>
	<20110302002353.GA15009@gondor.apana.org.au>
	<1299031203.2930.26.camel@edumazet-laptop>
	<20110302023920.GA16072@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Thomas Graf <tgraf@infradead.org>,
	David Miller <davem@davemloft.net>, rick.jones2@hp.com,
	wsommerfeld@google.com, daniel.baluta@gmail.com,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:8275 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750702Ab1CBHMc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 02:12:32 -0500
Received: from kpbe17.cbf.corp.google.com (kpbe17.cbf.corp.google.com [172.25.105.81])
	by smtp-out.google.com with ESMTP id p227CVsU006524
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 23:12:31 -0800
Received: from pzk28 (pzk28.prod.google.com [10.243.19.156])
	by kpbe17.cbf.corp.google.com with ESMTP id p227C3K2022105
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Tue, 1 Mar 2011 23:12:30 -0800
Received: by pzk28 with SMTP id 28so1187071pzk.35
        for <netdev@vger.kernel.org>; Tue, 01 Mar 2011 23:12:29 -0800 (PST)
In-Reply-To: <20110302023920.GA16072@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 1, 2011 at 6:39 PM, Herbert Xu <herbert@gondor.apana.org.au=
> wrote:
> On Wed, Mar 02, 2011 at 03:00:03AM +0100, Eric Dumazet wrote:
>> >
>> > Think about it, a TCP socket cannot be used by a multi-threaded ap=
p
>> > in a scalable way.
>>
>> Well...
>>
>> If you think about it, SO_REUSEPORT patch has exactly the same goal =
:
>
In a sense.  SO_RESUSEPORT for TCP is intended to provide a scalable
listener solution.  Sharing an established socket is not very
efficient, something like a multiplexing socket layer on top of TCP
might be good.

> UDP is a datagram protocol, TCP is not.
>
> Anyway, here is an alternate proposal. =A0When a TCP socket transmits
> for the first time (SYN or SYN-ACK), we pick a queue based on CPU and
> store it in the socket. =A0From then on we stick to that selection.
>
> We would only allow changes if we can ensure that all transmitted
> packets have left the queue. =A0Or we just never change it like we
> do now.
>
XPS does all this already.

> For datagram protocols we simply use the current CPU.
>
Probably need to set skb->ooo_okay (for UDP etc.) also so that XPS
will change queues.

Tom
