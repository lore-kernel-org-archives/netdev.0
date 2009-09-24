From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] inet_peer: Optimize inet_getid()
Date: Thu, 24 Sep 2009 21:57:08 +0200
Message-ID: <4ABBCF14.5070007@gmail.com>
References: <4ABBC2D8.2040901@gmail.com> <20090924123020.59a2ee6e@s6510>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:55683 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752973AbZIXT5H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Sep 2009 15:57:07 -0400
In-Reply-To: <20090924123020.59a2ee6e@s6510>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger a =E9crit :
> On Thu, 24 Sep 2009 21:04:56 +0200
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>=20
>> While investigating for network latencies, I found inet_getid() was =
a contention point
>> for some workloads.
>>
>> Fix is straightforward, using cmpxchg() instead of
>> a spin_lock_bh()/spin_unlock_bh() pair on a central lock.
>>
>> Another possibility was to use an atomic_t and atomic_add_return() b=
ut
>> the size of struct inet_peer object would had doubled on x86_64 beca=
use of
>> SLAB_HWCACHE_ALIGN constraint.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> I thought cmpxchg was not available on all architectures.

Good point Stephen, I forgot about non x86 arches ;)

I'll send an update with cmpxchg() if available, and atomic_t as fallba=
ck.
