From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Tue, 15 Jan 2008 10:09:09 -0500
Message-ID: <478CCC95.8030405@hp.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com> <478B8473.6080506@nortel.com> <478B943C.7080009@cosmosbay.com> <478BB722.1020004@nortel.com> <478BB904.3060903@cosmosbay.com> <478BBFE3.9030707@nortel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <dada1@cosmosbay.com>, Ray Lee <ray-lk@madrabbit.org>,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Chris Friesen <cfriesen@nortel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0026.austin.hp.com ([15.216.28.33]:41902 "EHLO
	g1t0026.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750912AbYAOPJL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 10:09:11 -0500
In-Reply-To: <478BBFE3.9030707@nortel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Friesen wrote:
> Eric Dumazet wrote:
>> Chris Friesen a =C3=A9crit :
>=20
>>> Based on the profiling information we're spending time in=20
>>> sctp_endpoint_lookup_assoc() which doesn't actually use hashes, so =
I=20
>>> can't see how the hash would be related.  I'm pretty new to SCTP=20
>>> though, so I may be missing something.
>>
>> Well, it does use hashes :)
>>
>>        hash =3D sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
>>        head =3D &sctp_assoc_hashtable[hash];
>>        read_lock(&head->lock);
>>        sctp_for_each_hentry(epb, node, &head->chain) {
>>            /* maybe your machine is traversing here a *really* long=20
>> chain */
>>            }
>=20
>=20
> The latest released kernel doesn't have this code, it was only added =
in=20
> November.  The SCTP maintainer just pointed me to the patch, and made=
=20
> some other suggestions as well.
>=20

Yes,  the hash code only got added to 2.6.24.  Before that, it was
a linear list traversal which sucked.

I need to take a look at the locking to see if we can further reduce
the time that bottom half is disabled.

-vlad
