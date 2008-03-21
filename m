From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [14/14] vcompound: Avoid vmalloc for ehash_locks
Date: Fri, 21 Mar 2008 08:42:08 +0100
Message-ID: <47E366D0.6090505@cosmosbay.com>
References: <20080321061727.491610308@sgi.com>	<47E35D73.6060703@cosmosbay.com>	<Pine.LNX.4.64.0803210002450.15903@schroedinger.engr.sgi.com> <20080321.003123.180348056.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: clameter@sgi.com, linux-mm@kvack.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:39204
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751602AbYCUHmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Mar 2008 03:42:12 -0400
In-Reply-To: <20080321.003123.180348056.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: Christoph Lameter <clameter@sgi.com>
> Date: Fri, 21 Mar 2008 00:03:51 -0700 (PDT)
>=20
>> On Fri, 21 Mar 2008, Eric Dumazet wrote:
>>
>>> But, isnt it defeating the purpose of this *particular* vmalloc() u=
se ?
>> I thought that was controlled by hashdist? I did not see it used her=
e and=20
>> so I assumed that the RR was not intended here.
>=20
> It's intended for all of the major networking hash tables.

Other networking hash tables uses alloc_large_system_hash(), which hand=
les=20
hashdist settings.

But this helper is __init only, so we can not use it for ehash_locks (c=
an be=20
allocated by DCCP module)


