From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 15:09:56 -0700
Message-ID: <46439834.4090406@hp.com>
References: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com> <46439189.5090907@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Stevens <dlstevens@us.ibm.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from palrel10.hp.com ([156.153.255.245]:34246 "EHLO palrel10.hp.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752004AbXEJWKB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 May 2007 18:10:01 -0400
In-Reply-To: <46439189.5090907@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Eric Dumazet wrote:
> David Stevens a =E9crit :
>=20
>> The word "small" is coming up a lot in this discussion, and
>> I think packet size really has nothing to do with it. Multiple
>> streams generating packets of any size would benefit; the
>> key ingredient is a queue length greater than 1.
>>
>> I think the intent is to remove queue lock cycles by taking
>> the whole list (at least up to the count of free ring buffers)
>> when the queue is greater than one packet, thus effectively
>> removing the lock expense for n-1 packets.
>>
>=20
> Yes, but on modern cpus, locked operations are basically free once th=
e=20
> CPU already has the cache line in exclusive access in its L1 cache.

But will it here?  Any of the CPUs are trying to add things to the qdis=
c, but=20
only one CPU is pulling from it right?  Even if the "pulling from it" i=
s=20
happening in a loop, there can be scores or more other cores trying to =
add=20
things to the queue, which would cause that cache line to migrate.

> I am not sure adding yet another driver API will help very much.
> It will for sure adds some bugs and pain.

That could very well be.

> A less expensive (and less prone to bugs) optimization would be to=20
> prefetch one cache line for next qdisc skb, as a cache line miss is f=
ar=20
> more expensive than a locked operation (if lock already in L1 cache o=
f=20
> course)

Might they not build on on top of the other?

rick jones


