From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PATCH] xt_quota: don't copy quota back to userspace
Date: Fri, 23 Jul 2010 14:10:14 +0200
Message-ID: <4C4986A6.60608@trash.net>
References: <1279860845-7177-1-git-send-email-xiaosuo@gmail.com>	 <1279862843.2482.16.camel@edumazet-laptop> <1279863633.2482.22.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:36658 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758990Ab0GWMKI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 23 Jul 2010 08:10:08 -0400
In-Reply-To: <1279863633.2482.22.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 23.07.2010 07:40, Eric Dumazet wrote:
> Le vendredi 23 juillet 2010 =E0 07:27 +0200, Eric Dumazet a =E9crit :
>> Le vendredi 23 juillet 2010 =E0 12:54 +0800, Changli Gao a =E9crit :
>>> This patch should be applied after my another patch:
>>> http://patchwork.ozlabs.org/patch/59729/
>>>
>>> xt_quota: don't copy quota back to userspace
>>>
>>> In nowadays, table entries are per-cpu variables, so it don't make =
any sense to
>>> copy quota back to one of the variable instances. To keep things si=
mple, this
>>> patch undo the copy.
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>
>> This looks the wrong way to fix this problem.
>>
>> Also Changli, could you please _not_ include the title of your patch=
es
>> inside the Changelog ? This is useless.
>>
>=20
> Reading again your patch, I understand only the Changelog is wrong.
>=20
> We want to copy quota back to userspace, as specified when rule was
> setup (so that iptables-save works)
>=20
> The real thing you are doing is that we dont change the initial quota
> during packet processing, only the private quota, shared by all cpus.
>=20
> Before the patch , iptables -nvL could report an old and not accurate
> quota value.
>=20
> After the patch, iptables -nvL reports the initial quota value, not t=
he
> actual value.

I've fixed up the changelog and applied the patch, thanks.

Changli, please also update the userspace extension to not ignore
the quota value on deletion.
