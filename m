From: "Chris Friesen" <cfriesen@nortel.com>
Subject: Re: questions on NAPI processing latency and dropped network packets
Date: Mon, 14 Jan 2008 14:02:43 -0600
Message-ID: <478BBFE3.9030707@nortel.com>
References: <478654C3.60806@nortel.com> <2c0942db0801112137k3f3f885ek212d5cbaecb7fea0@mail.gmail.com> <478B8473.6080506@nortel.com> <478B943C.7080009@cosmosbay.com> <478BB722.1020004@nortel.com> <478BB904.3060903@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ray Lee <ray-lk@madrabbit.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zrtps0kp.nortel.com ([47.140.192.56]:35070 "EHLO
	zrtps0kp.nortel.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753470AbYANUDc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 15:03:32 -0500
In-Reply-To: <478BB904.3060903@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Chris Friesen a =C3=A9crit :

>> Based on the profiling information we're spending time in=20
>> sctp_endpoint_lookup_assoc() which doesn't actually use hashes, so I=
=20
>> can't see how the hash would be related.  I'm pretty new to SCTP=20
>> though, so I may be missing something.
>=20
> Well, it does use hashes :)
>=20
>        hash =3D sctp_assoc_hashfn(ep->base.bind_addr.port, rport);
>        head =3D &sctp_assoc_hashtable[hash];
>        read_lock(&head->lock);
>        sctp_for_each_hentry(epb, node, &head->chain) {
>            /* maybe your machine is traversing here a *really* long=20
> chain */
>            }


The latest released kernel doesn't have this code, it was only added in=
=20
November.  The SCTP maintainer just pointed me to the patch, and made=20
some other suggestions as well.

Chris
