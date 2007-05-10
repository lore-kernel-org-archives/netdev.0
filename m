From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [RFC] New driver API to speed up small packets xmits
Date: Thu, 10 May 2007 23:41:29 +0200
Message-ID: <46439189.5090907@cosmosbay.com>
References: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>,
	Evgeniy Polyakov <johnpol@2ka.mipt.ru>,
	Krishna Kumar2 <krkumar2@in.ibm.com>, netdev@vger.kernel.org,
	netdev-owner@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:59890 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762099AbXEJVly (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 May 2007 17:41:54 -0400
In-Reply-To: <OF5ECC8062.FEB97ADC-ON882572D7.0075648E-882572D7.0075E0A6@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens a =E9crit :
> The word "small" is coming up a lot in this discussion, and
> I think packet size really has nothing to do with it. Multiple
> streams generating packets of any size would benefit; the
> key ingredient is a queue length greater than 1.
>=20
> I think the intent is to remove queue lock cycles by taking
> the whole list (at least up to the count of free ring buffers)
> when the queue is greater than one packet, thus effectively
> removing the lock expense for n-1 packets.
>=20

Yes, but on modern cpus, locked operations are basically free once the =
CPU=20
already has the cache line in exclusive access in its L1 cache.

I am not sure adding yet another driver API will help very much.
It will for sure adds some bugs and pain.

A less expensive (and less prone to bugs) optimization would be to pref=
etch=20
one cache line for next qdisc skb, as a cache line miss is far more exp=
ensive=20
than a locked operation (if lock already in L1 cache of course)


