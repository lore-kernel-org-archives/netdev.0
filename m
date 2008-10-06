From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when	gc_elasticity
 is exceeded
Date: Mon, 06 Oct 2008 23:21:38 +0200
Message-ID: <48EA8162.4050409@cosmosbay.com>
References: <48E1C104.2080801@cosmosbay.com> <20080930.071023.07946874.davem@davemloft.net> <48E25F02.8030303@cosmosbay.com> <20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com> <48E470AC.10305@cosmosbay.com> <48E4832A.3070804@cosmosbay.com> <20081003003158.GA19230@localhost.localdomain> <20081003203640.GA13354@hmsreliant.think-freely.org> <48E9ED3D.2020005@cosmosbay.com> <20081006205422.GD16939@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Bill Fink <billfink@mindspring.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2a.orange.fr ([80.12.242.140]:31483 "EHLO smtp2a.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752915AbYJFVV5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 17:21:57 -0400
In-Reply-To: <20081006205422.GD16939@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman a =E9crit :
> So, I've been playing with this patch, and I've not figured out eactl=
y whats
> bothering me yet, since the math seems right, but something doesn't s=
eem right
> about the outcome of this algorithm.  I've tested with my local syste=
m, and all
> works well, because the route cache is well behaved, and the sd value=
 always
> works out to be very small, so ip_rt_gc_elasticity is used.  So I've =
been
> working through some scenarios by hand to see what this looks like us=
ing larger
> numbers.  If i assume ip_rt_gc_interval is 60, and rt_hash_log is 17,=
 my sample
> count here is 7864320 samples per run.  If within that sample 393216 =
(about 4%)
> of the buckets have one entry on the chain, and all the rest are zero=
s, my hand
> calculations result in a standard deviation of approximately 140 and =
an average
> of .4.  That imples that in that sample set any one chain could be al=
most 500
> entires long before it triggered a cache rebuld.  Does that seem reas=
onable?
>=20

if rt_hash_log is 17, and interval is 60, then you should scan=20
(60 << 17)/300 slots. That's 26214 slots. (ie 20% of the 2^17 slots)

I have no idea how you can have sd =3D 140, even if scaled by (1 << 3)
with slots being empty or with one entry only...

If 4% of your slots have one element, then average length is 0.04 :)





