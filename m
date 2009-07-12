From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
Date: Sun, 12 Jul 2009 09:07:23 +0200
Message-ID: <4A598BAB.6030400@gmail.com>
References: <20090707.191424.167842005.davem@davemloft.net>	<4A5441A0.3050504@gmail.com>	<4A5581C5.5070409@gmail.com> <20090711.202727.18146102.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emil.s.tantilov@intel.com, emils.tantilov@gmail.com,
	netdev@vger.kernel.org, jesse.brandeburg@intel.com,
	jeffrey.t.kirsher@intel.com, jolsa@redhat.com, kaber@trash.net,
	paulmck@linux.vnet.ibm.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:50958 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbZGLHHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jul 2009 03:07:54 -0400
In-Reply-To: <20090711.202727.18146102.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Thu, 09 Jul 2009 07:36:05 +0200
>=20
>> [PATCH] net: sk_prot_alloc() should not blindly overwrite memory
>>
>> Some sockets use SLAB_DESTROY_BY_RCU, and our RCU code correctness
>> depends on sk->sk_nulls_node.next being always valid. A NULL
>> value is not allowed as it might fault a lockless reader.
>>
>> Current sk_prot_alloc() implementation doesnt respect this hypothesi=
s,
>> calling kmem_cache_alloc() with __GFP_ZERO. Just call memset() aroun=
d
>> the forbidden field.
>>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>=20
> APplied and queued up for -stable.

I'll try to find some time to fix netfilter conntrack as well.

Thanks
