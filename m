From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [Bugme-new] [Bug 8536] New: Kernel drops UDP packets silently
 when reading from certain proc file entries
Date: Fri, 25 May 2007 08:50:20 +0200
Message-ID: <4656872C.9000701@cosmosbay.com>
References: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	netdev@vger.kernel.org, bugme-daemon@bugzilla.kernel.org,
	andsve@gmail.com
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:44321 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752045AbXEYGvE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 May 2007 02:51:04 -0400
In-Reply-To: <E1HrTDQ-0006qu-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu a =E9crit :
> Andrew Morton <akpm@linux-foundation.org> wrote:
>>> It is possible to introduce UDP packet losses by reading
>>> the proc file entry /proc/net/tcp. The really strange thing is that
>>> the error counters for packet drops are not increased.=20
>=20
> Please try this patch and let us know if it helps.
>=20
> [TCPv4]: Improve BH latency in /proc/net/tcp
>=20
> Currently the code for /proc/net/tcp disable BH while iterating
> over the entire established hash table.  Even though we call
> cond_resched_softirq for each entry, we still won't process
> softirq's as regularly as we would otherwise do which results
> in poor performance when the system is loaded near capacity.
>=20
> This anomaly comes from the 2.4 code where this was all in a
> single function and the local_bh_disable might have made sense
> as a small optimisation.
>=20
> The cost of each local_bh_disable is so small when compared
> against the increased latency in keeping it disabled over a
> large but mostly empty TCP established hash table that we
> should just move it to the individual read_lock/read_unlock
> calls as we do in inet_diag.
>=20

But its not really true : cond_resched_softirq() is called for
each bucket in hash table, empty or not.


If this patch really helps, this means cond_resched_softirq()
doesnt work at all and should be fixed, or just zapped as it
is seldom used.

