From: =?ISO-8859-1?Q?Timo_Ter=E4s?= <timo.teras@iki.fi>
Subject: Re: xfrm transport mode policy and forward packets
Date: Thu, 22 Oct 2009 16:31:20 +0300
Message-ID: <4AE05EA8.5070700@iki.fi>
References: <4AE04B00.8090207@iki.fi> <20091022132126.GB28893@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gv-out-0910.google.com ([216.239.58.187]:4818 "EHLO
	gv-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755756AbZJVNbM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2009 09:31:12 -0400
Received: by gv-out-0910.google.com with SMTP id r4so903882gve.37
        for <netdev@vger.kernel.org>; Thu, 22 Oct 2009 06:31:16 -0700 (PDT)
In-Reply-To: <20091022132126.GB28893@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Herbert Xu wrote:
> On Thu, Oct 22, 2009 at 03:07:28PM +0300, Timo Ter=E4s wrote:
>> I'm using on my dmvpn environment security policies like:
>>
>> src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 	dir in priority 2147483648 pt=
ype=20
>> main 	tmpl src 0.0.0.0 dst 0.0.0.0
>> 		proto esp reqid 0 mode transport
>>
>> src 0.0.0.0/0 dst 0.0.0.0/0 proto gre 	dir out priority 2147483648 p=
type=20
>> main 	tmpl src 0.0.0.0 dst 0.0.0.0
>> 		proto esp reqid 0 mode transport
>>
>> To make sure the locally generated/received GRE traffic is IPsec pro=
tected.
>> Now when some other non-local gre traffic is being forwarded by this=
 router,
>> that seems to match these SPs too. Basically no one behind this rout=
er box
>> can use GRE (or PPTP).
>=20
> This is expected since forwarded GRE packets match the selector
> given.

Yes. I forgot to explicitly mention, that I thought just removing the
'fwd' policy would fix this. It's slightly confusing that that input pa=
th
is split to two separate policy db's, while output is not.

>> My ideas so far have been:
>> a) rename 'fwd' to 'infwd' and split 'out' to 'out' and 'outfwd' ?
>>   (sounds kinda intrusive)
>> b) iptables target that would be able to disable xfrm
>>
>> Any other ideas?
>> What would be the proper fix for this problem?
>=20
> We could add the fwmark as a key.

Ah, sounds even better.

> Alexey and others may have better ideas on this.

Thanks!
 Timo
