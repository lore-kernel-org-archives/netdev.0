From: Richard Weinberger <richard@nod.at>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on
 opening /dev/ppp
Date: Sun, 19 Jun 2016 12:40:49 +0200
Message-ID: <576676B1.8010206@nod.at>
References: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn>
 <5766704C.6060309@nod.at>
 <C708B373-7946-458A-A4C2-BB63A2413FB6@tuna.tsinghua.edu.cn>
Mime-Version: 1.0
Content-Type: text/plain; charset=gbk
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Guillaume Nault <g.nault@alphalink.fr>
To: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Return-path: <netdev-owner@vger.kernel.org>
Received: from b.ns.miles-group.at ([95.130.255.144]:44723 "EHLO radon.swed.at"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1751565AbcFSKkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 19 Jun 2016 06:40:53 -0400
In-Reply-To: <C708B373-7946-458A-A4C2-BB63A2413FB6@tuna.tsinghua.edu.cn>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 19.06.2016 um 12:36 schrieb Shanker Wang:
>=20
>> =D4=DA 2016=C4=EA6=D4=C219=C8=D5=A3=AC12:13=A3=ACRichard Weinberger =
<richard@nod.at> =D0=B4=B5=C0=A3=BA
>>
>> Am 19.06.2016 um 07:21 schrieb Shanker Wang:
>>> This patch removes the check for CAP_NET_ADMIN in the initial names=
pace
>>> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the us=
er
>>> namespace the net namespace was created so that /dev/ppp cat get op=
ened
>>> in a unprivileged container.
>>>
>>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>>> Cc: Richard Weinberger <richard.weinberger@gmail.com>
>>> Cc: Guillaume Nault <g.nault@alphalink.fr>
>>> Cc: Miao Wang <shankerwangmiao@gmail.com>
>>> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>
>>> ---
>>> drivers/net/ppp/ppp_generic.c | 2 +-
>>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>>
>>> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_ge=
neric.c
>>> index f572b31..4b3b2b5 100644
>>> --- a/drivers/net/ppp/ppp_generic.c
>>> +++ b/drivers/net/ppp/ppp_generic.c
>>> @@ -380,7 +380,7 @@ static int ppp_open(struct inode *inode, struct=
 file *file)
>>> 	/*
>>> 	 * This could (should?) be enforced by the permissions on /dev/ppp=
=2E
>>> 	 */
>>> -	if (!capable(CAP_NET_ADMIN))
>>> +	if (!ns_capable(current->nsproxy->net_ns->user_ns, CAP_NET_ADMIN)=
)
>>> 		return -EPERM;
>>
>> Shouldn't this be a ns_capable(net->user_ns, =A1=AD?
>> Otherwise an user can create a new user_ns followed by a new net_ns =
and has
>> CAP_NET_ADMIN. We need to check whether he is allowed in the user_ns=
 of the
>> net_ns which belongs to the ppp net device which you want to open.
> You are totally right. However, I wonder how can i get the =A1=B0net=A1=
=B1 struct when=20
> opening /dev/ppp

I'm sure you can get it somehow via file->private_data.

Thanks,
//richard
