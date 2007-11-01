From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH 0/5] Make nicer CONFIG_NET_NS=n case code
Date: Thu, 01 Nov 2007 07:58:59 +0100
Message-ID: <47297933.7090609@cosmosbay.com>
References: <4728D54F.2080208@openvz.org>	<20071031194924.2436843e.dada1@cosmosbay.com>	<m1hck7hrd1.fsf@ebiederm.dsl.xmission.com>	<4729047B.3080003@cosmosbay.com> <m1wst2hjo5.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Pavel Emelyanov <xemul@openvz.org>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:40573 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753219AbXKAG7L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Nov 2007 02:59:11 -0400
In-Reply-To: <m1wst2hjo5.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric W. Biederman a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>=20
>> Eric W. Biederman a =E9crit :
>>> Eric Dumazet <dada1@cosmosbay.com> writes:
>>>
>>>
>>>> Definitly wanted here. Thank you.
>>>> One more refcounting on each socket creation/deletion was expensiv=
e.
>>> Really?  Have you actually measured that?  If the overhead is
>>> measurable and expensive we may want to look at per cpu counters or
>>> something like that.  So far I don't have any numbers that say any
>>> of the network namespace work inherently has any overhead.
>> It seems that on some old opterons (two 246 for example),
>> "if (atomic_dec_and_test(&net->count))" is rather expensive yes :(
>=20
> I won't argue that atomic_dec_and_test is costly.  My gut feel is tha=
t
> socket creation/destruction is sufficiently rare that such a test
> would be lost in the noise.  Doing anything more sophisticated is
> likely to be less readable, and unless we can measure some overhead
> my preference right now is to keep the code stupid and simple.  Which
> usually has a good icache footprint.

I agree with you that with current state, this atomic_inc/atomic_dec_an=
d_test=20
wont come in profiles unless a trivial bench is writen

for(;;){close(socket(....));}

If David or another dev can eliminate the atomic inc/dec on device refc=
ount=20
cost for each packet traveling, the socket creation/destruction would=20
certainly raise.

Other contention points is the mnt_count (yet another refcount) in "str=
uct=20
vfsmount", a truly useless refcount as I never had (and nobody had) to=20
un-mount sock_mnt :)


