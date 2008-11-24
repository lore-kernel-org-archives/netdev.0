From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: net-next/unix: BUG: using smp_processor_id() in preemptible
Date: Mon, 24 Nov 2008 06:51:06 +0100
Message-ID: <492A40CA.1070005@cosmosbay.com>
References: <Pine.LNX.4.64.0811221634370.10534@wrl-59.cs.helsinki.fi>	<4928CECE.602@cosmosbay.com>	<20081123.172014.78676422.davem@davemloft.net> <20081123.173426.255648175.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ilpo.jarvinen@helsinki.fi, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([86.65.150.130]:42462 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750784AbYKXFvV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Nov 2008 00:51:21 -0500
In-Reply-To: <20081123.173426.255648175.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller a =E9crit :
> From: David Miller <davem@davemloft.net>
> Date: Sun, 23 Nov 2008 17:20:14 -0800 (PST)
>=20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Sun, 23 Nov 2008 04:32:30 +0100
>>
>>> [PATCH] net: make sock_prot_inuse_add() preempt safe
>  ...
>> Eric, you added this bug by starting to use this interface in
>> situations where BH's were not disabled.
>>
>> Ever existing use adhered to that rule.
>>
>> If you therefore want to call this interface in new locations,
>> you have to make sure those locations follow the rule too.
>=20
> Here is what I commited to fix this bug.
>=20
> net: Make sure BHs are disabled in sock_prot_inuse_add()
>=20
> The rule of calling sock_prot_inuse_add() is that BHs must
> be disabled.  Some new calls were added where this was not
> true and this tiggers warnings as reported by Ilpo.
>=20
> Fix this by adding explicit BH disabling around those call sites.
>=20
> Signed-off-by: David S. Miller <davem@davemloft.net>
> ---
>  net/netlink/af_netlink.c |    3 +++
>  net/sctp/socket.c        |    4 ++++
>  net/unix/af_unix.c       |    2 ++
>  3 files changed, 9 insertions(+), 0 deletions(-)

Hello David

Thanks for working on this during my sleep ;)


