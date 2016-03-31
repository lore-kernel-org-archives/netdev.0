From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: Question on rhashtable in worst-case scenario.
Date: Thu, 31 Mar 2016 17:29:59 +0200
Message-ID: <1459438199.4576.26.camel@sipsolutions.net>
References: <56F9941A.3080501@candelatech.com>
	 <56FAAA6D.3070806@candelatech.com>
	 <1459329252.2055.1.camel@sipsolutions.net>
	 <20160330.123821.328761526754742195.davem@davemloft.net>
	 <56FC0445.6010200@candelatech.com>
	 <1459410405.4576.8.camel@sipsolutions.net>
	 <20160331075015.GA27716@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
	netdev@vger.kernel.org, tgraf@suug.ch
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([5.9.151.49]:45730 "EHLO sipsolutions.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbcCaPaG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 31 Mar 2016 11:30:06 -0400
In-Reply-To: <20160331075015.GA27716@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-03-31 at 15:50 +0800, Herbert Xu wrote:
> On Thu, Mar 31, 2016 at 09:46:45AM +0200, Johannes Berg wrote:
> >=20
> >=20
> > In this case, I think perhaps you can just patch your local system
> > with
> > the many interfaces connecting to the same AP to add the parameter
> > Herbert suggested (.insecure_elasticity =3D true in sta_rht_params)=
=2E
> > This
> > is, after all, very much a case that "normal" operation doesn't
> > even
> > get close to.
> I think you should just turn it on everywhere for mac80211.=C2=A0=C2=A0=
Chain
> length checks simply don't make sense when you allow duplicate
> keys in the hash table.

Yes, that's a good point, and we can - in certain corner cases - end up
with duplicate keys even in normal operation.

Does removing this completely disable the "-EEXIST" error? I can't say
I fully understand the elasticity stuff in __rhashtable_insert_fast().

johannes
