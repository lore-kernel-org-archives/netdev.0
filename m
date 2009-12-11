From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RT metric sharing...
Date: Fri, 11 Dec 2009 01:22:41 +0100
Message-ID: <4B2190D1.9080505@gmail.com>
References: <20091210.141438.78359022.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:58554 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757420AbZLKAWh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2009 19:22:37 -0500
In-Reply-To: <20091210.141438.78359022.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 10/12/2009 23:14, David Miller a =E9crit :
>=20
> This topic has come up a few times, but I had a reason to
> consider it again.
>=20
> The routing metrics take up quite a bit of space in the
> dst_entry and thus every routing cache entry.
>=20
> We could save some space with indirection.
>=20
> Basically my idea is:
>=20
> 1) dst_metrics are maintained in external structure
>=20
> 2) when cache entry is created, read-only dst_metrics object
>    is allocated for it
>=20
> 3) any attempt to change the metrics of such a read-only dst_entry
>    cow's it, all further writes proceed as normal
>=20
> We currently have 13 (so 13 * sizeof(u32) =3D=3D 52) and we're probab=
ly
> about to get a 14th (for the initial receive window stuff).
>=20

Nice idea Dave.

(Note : we do have a hole available for the 14th metric
because of forced __refcnt alignement)
