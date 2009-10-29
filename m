From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix kmemcheck annotations
Date: Thu, 29 Oct 2009 11:44:48 +0100
Message-ID: <4AE97220.3000004@gmail.com>
References: <4AE96A1D.8050300@gmail.com> <20091029.031748.235701096.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:43648 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750766AbZJ2Koq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2009 06:44:46 -0400
In-Reply-To: <20091029.031748.235701096.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
>=20
> We may be trading size for performance here, I wonder if
> it's wise to move queue_mapping like that and what
> locality change we get as a result.

I agree, but could not convince me it makes a difference.

On 64bit arches, queue_mapping doesnt change its cache line location
(0xa4 -> 0xa8)

On 32bit arches, sizeof(sk_buf)=3D0xB0, rx and tx paths touch all
 of 3 cache lines anyway.

Only thing I can think at this moment is to reorder skb so that TX=20
completion path dont touch all cache lines (putting together cb[]=20
and some not touched fields). We could probably gain one cache line mis=
s.

It's a bit hard because of the next/prev fields that must
be first members of structure, but I believe you had some work in progr=
ess
in this area, to stick a standard list_head ?

