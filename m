From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] net: implement emergency route cache rebulds when gc_elasticity
 is exceeded
Date: Thu, 02 Oct 2008 08:56:44 +0200
Message-ID: <48E470AC.10305@cosmosbay.com>
References: <48E141F3.9000903@cosmosbay.com>	<20080929223801.GA3157@hmsreliant.think-freely.org>	<48E1C104.2080801@cosmosbay.com>	<20080930.071023.07946874.davem@davemloft.net>	<48E25F02.8030303@cosmosbay.com>	<20081001180846.GB3566@hmsreliant.think-freely.org> <20081002010101.6f0a1fa5.billfink@mindspring.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>
To: Bill Fink <billfink@mindspring.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2f.orange.fr ([80.12.242.152]:6354 "EHLO smtp2f.orange.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751764AbYJBG51 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 2 Oct 2008 02:57:27 -0400
In-Reply-To: <20081002010101.6f0a1fa5.billfink@mindspring.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bill Fink a =C3=A9crit :
> On Wed, 1 Oct 2008, Neil Horman wrote:
>=20
>> Hey all-
>> 	Since Eric mentioned the use of statistical analysis to determine i=
f
>> hash chains were growing improperly, I thought I would take a stab a=
t such an
>> approach.  I'm no statistics expert, but it would seem to me that si=
mply
>> computing the standard deviation of all the non-zero chain lengths w=
ould give a
>> good guide point to determine if we needed to invalidate our hash ta=
ble.  I've
>> written the below implementation.  I've not tested it (I'll be doing=
 that here
>> shortly for the next few days), but I wanted to post it to get feedb=
ack from you
>> all on the subject.  The highlights are:
>>
>> 1) We add a counter to rt_hash_bucket structure to track the length =
of each
>> individual chain.  I realize this is sub-optimal, as it adds potenti=
ally lots of
>> memory to hash table as a whole (4 bytes * number of hash buckets). =
 I'm afraid
>> I've not come up with a better way to track that yet.  We also track=
 the total
>> number of route entries and the number of non-zero length chains.  L=
astly we
>> also maintain a global maximum chain length which defines the longes=
t chain we
>> will tolerate in the route table.  This patch defines it as the mean=
 chain
>> length plus one standard deviation.
>=20
> I believe the general rule of thumb for something like this is at
> least two standard deviations.  For a normal distribution, one standa=
rd
> deviation covers about 68 % of the sample universe, while two standar=
d
> deviations covers about 95 % (three standard deviations covers 99.73 =
%).
> See the Wikipedia entry:
>=20
> 	http://en.wikipedia.org/wiki/Standard_deviation
>=20

Thanks Bill for the pointer, this is the trick.

I believe we should target "4=CF=83 99.993666% " case.

But we dont need to really compute Standard deviation at runtime, only =
find an (upper) approximation of it.

=46or elasticity=3D4 and 512*1024 samples (mean < 4), I guess 4=CF=83 c=
an be approximated by 20 or something.

Thank you



