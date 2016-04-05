From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [net PATCH v2 2/2] ipv4/GRO: Make GRO conform to RFC 6864
Date: Tue, 05 Apr 2016 09:30:06 -0700
Message-ID: <1459873806.6473.358.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160404162545.14332.653.stgit@localhost.localdomain>
	 <20160404162818.14332.1076.stgit@localhost.localdomain>
	 <20160405034437.GA9322@gondor.apana.org.au>
	 <CAKgT0UfcqBUTY1SxawwKdnzS7qW7XggjzpKNcfT3cTSZ9DHMmA@mail.gmail.com>
	 <20160405043209.GA9822@gondor.apana.org.au>
	 <CAKgT0Uc=9MMzSHWgZib5+EwPCQokjSSnC9vfOtWKULvmwUQpdQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Alexander Duyck <aduyck@mirantis.com>,
	Tom Herbert <tom@herbertland.com>,
	Jesse Gross <jesse@kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>
To: Alexander Duyck <alexander.duyck@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f193.google.com ([209.85.161.193]:35016 "EHLO
	mail-yw0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758746AbcDEQaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 5 Apr 2016 12:30:09 -0400
Received: by mail-yw0-f193.google.com with SMTP id v185so2612685ywd.2
        for <netdev@vger.kernel.org>; Tue, 05 Apr 2016 09:30:09 -0700 (PDT)
In-Reply-To: <CAKgT0Uc=9MMzSHWgZib5+EwPCQokjSSnC9vfOtWKULvmwUQpdQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-04-05 at 08:52 -0700, Alexander Duyck wrote:

>=20
> I disagree I think it will have to be part of the default
> configuration.  The problem is the IP ID is quickly becoming
> meaningless.  When you consider that a 40Gb/s link can wrap the IP ID
> value nearly 50 times a second using a 1500 MTU the IP ID field shoul=
d
> just be ignored anyway because you cannot guarantee that it will be
> unique without limiting the Tx window size.  That was the whole point
> of RFC6864.  Basically the IP ID field is so small that as we push
> into the higher speeds you cannot guarantee that the field will have
> any meaning so for any case where you don't need to use it you
> shouldn't because it will likely not provide enough useful data.

Just because a few flows reach 40Gbit , we should remind that vast
majority of the Internet runs with < 50Mbits flows.

I prefer the argument of IPv6 not having ID ;)

We should do our best to keep interoperability, this is the selling
point.=20

And quite frankly your last patch makes perfect sense to me :

The aggregation is done only if the TCP headers of consecutive packets
matches. So who cares of IPv4 ID really ?
This is a very minor detail. The possible gains outperform the
theoretical 'problem'

GRO already reorder flows, it never had a guarantee of being '=C3=ADnvi=
sible'
as Herbert claims.
