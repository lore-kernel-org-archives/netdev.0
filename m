From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: [PATCH] af_key: parse and send SADB_X_EXT_NAT_T_OA extension
Date: Thu, 22 Jan 2009 12:00:22 +0200
Message-ID: <497843B6.8090407@iki.fi>
References: <49780EB5.60300@iki.fi> <20090121.222112.245293949.davem@davemloft.net> <20090122063206.GA11818@gondor.apana.org.au> <497814A7.3060302@iki.fi> <20090122064719.GA12043@gondor.apana.org.au> <4978180A.6080304@iki.fi> <20090122073946.GB12395@gondor.apana.org.au> <49782EE4.2070809@iki.fi> <20090122085053.GA12806@gondor.apana.org.au> <49783B59.90208@iki.fi> <20090122094150.GB14491@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fk-out-0910.google.com ([209.85.128.185]:61711 "EHLO
	fk-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755269AbZAVKA2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Jan 2009 05:00:28 -0500
Received: by fk-out-0910.google.com with SMTP id f33so631437fkf.5
        for <netdev@vger.kernel.org>; Thu, 22 Jan 2009 02:00:26 -0800 (PST)
In-Reply-To: <20090122094150.GB14491@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


[Offtopic: looking latest openswan code it does look a lot
better too. It looked quite different when checked it out
some years ago.]

Herbert Xu wrote:
> On Thu, Jan 22, 2009 at 11:24:41AM +0200, Timo Ter=E4s wrote:
>> In DMVPN/GRE case, the NAT-OA from IPsec would not be used
>> unless the NAT-OA is set on neighbour cache. This would not
>> happen unless NHRP can authenticate it. In DMVPN case you need
>> a valid certificate to give the ranom NAT-OA in any case. So
>> if you lie about your NAT-OA I can just revoke you.
>=20
> I don't see how NHRP authentication would help if the attacker
> takes over someone else's address and causes packets for the
> third party to go to it.
>=20
> As to revoking the attacker's access, that's like saying "I'll
> run an open telnet port but if you try to sniff my psasword I'll
> revoke your access" :)

Sorry, I misunderstood the point in the beginning. Yes, if
someone else has valid cert, and has possession of the same
public IP and knows the private-ip I am using, and makes
SA with that info, he might be able to steal my traffic.

Good point.

And thinking more about it, NAT-OA might be even same for
multiple separate clients (if they are double natted).

>> Or do you have, other recommendations how to distinguish peers
>> behind same public IP than NAT-OA? Maybe we add the certificate
>> subject to xfrm state and neighbour cache. And use that?
>=20
> Yes I think that is a much better solution for this.

Still, connecting it with variable amount length of data
(like cert subject) might be cumbersome (extending the
APIs, structs, especially neighbor cache).

Then again it might not be easy to come up with identifying
information if we limit it to 32-bits or 64-bits or so.

Ok, I'll think about this more. Ideas would be appreciated
here.

- Timo

