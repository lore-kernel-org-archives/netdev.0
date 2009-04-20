From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Network latency regressions from 2.6.22 to 2.6.29 (results with
 IRQ affinity)
Date: Mon, 20 Apr 2009 22:07:00 +0200
Message-ID: <49ECD5E4.60100@cosmosbay.com>
References: <49E78A79.6050604@cosmosbay.com> <49E78C1E.9060405@cosmosbay.com> <alpine.DEB.1.10.0904161555040.23632@qirst.com> <20090416.160002.09845606.davem@davemloft.net> <alpine.DEB.1.10.0904171238550.20049@qirst.com> <49EA2D7F.3080405@cosmosbay.com> <alpine.DEB.1.10.0904201305360.1585@qirst.com> <49ECB775.6030202@cosmosbay.com> <alpine.DEB.1.10.0904201410430.3361@qirst.com> <49ECC30A.9040501@cosmosbay.com> <alpine.DEB.1.10.0904201510410.17816@qirst.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Michael Chan <mchan@broadcom.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	netdev@vger.kernel.org
To: Christoph Lameter <cl@linux.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55799 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754280AbZDTUHq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Apr 2009 16:07:46 -0400
In-Reply-To: <alpine.DEB.1.10.0904201510410.17816@qirst.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Christoph Lameter a =E9crit :
> On Mon, 20 Apr 2009, Eric Dumazet wrote:
>=20
>> Point is that even with tcpdump running, latencies are very good on =
2.6.30-rc2, and were very good
>> with 2.6.22. I see no significant increase/decrease...
>=20
> Well okay that applies to your testing methodology but the statement =
that
> you have shown that the regression that I reported does not exist is =
not
> proven since you ran a different test.

I ran half the test. Receiver is OK, and this is the latency we all exp=
ect, as
service provider.

Now you can focus to the sender point.

=46or example, your program uses a kernel service to gather time with n=
anosecond precision.

Maybe there is a problem with it, I dont know...

Your test has so many variables it his hard to guess which part has a p=
roblem.

Maybe this is what you wanted to show after all, and you are not really=
 interested
to really discover what is happening. Oh well, just kidding.

I am not trying to say you are right or wrong Christoph, just trying to=
=20
check if really linux got a regression in various past releases. So far=
,
I did not found some strange results on UDP path, once IRQ affinities
are fixed of course.

>=20
>> 1 us is time to access about 10 false shared cache lines.
>=20
> That depends on the size of the system and the number of processors
> contending for the cache line.
>=20
>> 64 bit arches store less pointers/long per cache line.
>> So a 64 bit kernel could be slower on this kind of workload in the g=
eneral case (if several cpus play the game)
>=20
> Right. But in practice I have also seen slight performance increases =
due
> to the increased availability of memory and the avoidence of various =
32
> bit hacks (like highmem). Plus several recent subsystems seem to be
> optimized for 64 bit like f.e. Infiniband.

Maybe, but on udpping of 40 bytes messages, I am not sure it can make a=
 difference.

>=20
> I'd still like to see udpping results on your testing rigg to get ano=
ther
> datapoint. If the udpping results are not showing regressions on your
> tests then there is likely a config issue at the core of the regressi=
on
> that I am seeing here.

No changes in udpping but noise.

Also, my machines use bonding and vlans, so I probably have a litle bit=
 of overhead
(bonding uses rwlock, not very SMP friendly...)


