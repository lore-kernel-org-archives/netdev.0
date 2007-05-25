From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently
 when reading from certain proc file entries
Date: Fri, 25 May 2007 09:15:17 +0200
Message-ID: <46568D05.9080309@cosmosbay.com>
References: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au> <4656872C.9000701@cosmosbay.com> <20070525065712.GA26619@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	andsve@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:41671 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750854AbXEYHPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 03:15:36 -0400
In-Reply-To: <20070525065712.GA26619@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> On Fri, May 25, 2007 at 08:50:20AM +0200, Eric Dumazet wrote:
>> If this patch really helps, this means cond_resched_softirq()
>> doesnt work at all and should be fixed, or just zapped as it
>> is seldom used.
>=20
> cond_resched_softirq lets other threads run if they want to.
> It doesn't run pending softirq's at all.  In fact, it doesn't
> even wake up ksoftirqd.

I am very glad you fixed /proc/net/tcp, but I would like to
understand why this cond_resched_softirq() even exist.

Its name and behavior dont match at all.

The only remaining use is in __release_sock().

Should we schedule threads, or ksoftirqd as well in this function ?


