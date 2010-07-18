From: David Miller <davem@davemloft.net>
Subject: Re: Badness with the kernel version 2.6.35-rc1-git1 running on P6
 box
Date: Sun, 18 Jul 2010 14:51:20 -0700 (PDT)
Message-ID: <20100718.145120.35845833.davem@davemloft.net>
References: <4C401D56.3070108@linux.vnet.ibm.com>
	<1279274185.2549.14.camel@edumazet-laptop>
	<1279282842.2549.16.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: dipraksh@linux.vnet.ibm.com, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, sachinp@linux.vnet.ibm.com,
	benh@kernel.crashing.org, netdev@vger.kernel.org,
	ossthema@de.ibm.com
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:33842
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1757331Ab0GRVvE convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jul 2010 17:51:04 -0400
In-Reply-To: <1279282842.2549.16.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Fri, 16 Jul 2010 14:20:42 +0200

> Le vendredi 16 juillet 2010 =E0 11:56 +0200, Eric Dumazet a =E9crit :
>=20
>> [PATCH] ehea: ehea_get_stats() should use GFP_KERNEL
>>=20
>> ehea_get_stats() is called in process context and should use GFP_KER=
NEL
>> allocation instead of GFP_ATOMIC.
>>=20
>> Clearing stats at beginning of ehea_get_stats() is racy in case of
>> concurrent stat readers.
>>=20
>> get_stats() can also use netdev net_device_stats, instead of a priva=
te
>> copy.
>>=20
>> Reported-by: divya <dipraksh@linux.vnet.ibm.com>
>> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
>> ---
>>  drivers/net/ehea/ehea.h      |    1 -
>>  drivers/net/ehea/ehea_main.c |    6 ++----
>>  2 files changed, 2 insertions(+), 5 deletions(-)
>>=20
>>=20
>=20
> Hmm, net-next-2.6 contains following patch :

If people think ehea usage is ubiquitous enough to deserve a backport
of this to net-2.6, fine.  But personally I don't think it's worth it.

Can someone close the kernel bugzilla 16406 created for this bug?  This
patch we have already obviously would fix this issue.
