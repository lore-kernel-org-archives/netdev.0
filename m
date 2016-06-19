From: Shanker Wang <miao.wang@tuna.tsinghua.edu.cn>
Subject: Re: [PATCH] net:ppp: replace too strict capability restriction on opening /dev/ppp
Date: Sun, 19 Jun 2016 12:36:36 +0200
Message-ID: <C708B373-7946-458A-A4C2-BB63A2413FB6@tuna.tsinghua.edu.cn>
References: <15AED149-BC4D-4B8F-B173-3F652A46FA35@tuna.tsinghua.edu.cn> <5766704C.6060309@nod.at>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=gb2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Richard Weinberger <richard.weinberger@gmail.com>,
	Guillaume Nault <g.nault@alphalink.fr>
To: Richard Weinberger <richard@nod.at>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:35161 "EHLO
	mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751461AbcFSKgj convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 19 Jun 2016 06:36:39 -0400
Received: by mail-wm0-f67.google.com with SMTP id a66so2345079wme.2
        for <netdev@vger.kernel.org>; Sun, 19 Jun 2016 03:36:38 -0700 (PDT)
In-Reply-To: <5766704C.6060309@nod.at>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> =D4=DA 2016=C4=EA6=D4=C219=C8=D5=A3=AC12:13=A3=ACRichard Weinberger <=
richard@nod.at> =D0=B4=B5=C0=A3=BA
>=20
> Am 19.06.2016 um 07:21 schrieb Shanker Wang:
>> This patch removes the check for CAP_NET_ADMIN in the initial namesp=
ace
>> when opening /dev/open. Instead, CAP_NET_ADMIN is checked in the use=
r
>> namespace the net namespace was created so that /dev/ppp cat get ope=
ned
>> in a unprivileged container.
>>=20
>> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>
>> Cc: Richard Weinberger <richard.weinberger@gmail.com>
>> Cc: Guillaume Nault <g.nault@alphalink.fr>
>> Cc: Miao Wang <shankerwangmiao@gmail.com>
>> Signed-off-by: Miao Wang <miao.wang@tuna.tsinghua.edu.cn>
>> ---
>> drivers/net/ppp/ppp_generic.c | 2 +-
>> 1 file changed, 1 insertion(+), 1 deletion(-)
>>=20
>> diff --git a/drivers/net/ppp/ppp_generic.c b/drivers/net/ppp/ppp_gen=
eric.c
>> index f572b31..4b3b2b5 100644
>> --- a/drivers/net/ppp/ppp_generic.c
>> +++ b/drivers/net/ppp/ppp_generic.c
>> @@ -380,7 +380,7 @@ static int ppp_open(struct inode *inode, struct =
file *file)
>> 	/*
>> 	 * This could (should?) be enforced by the permissions on /dev/ppp.
>> 	 */
>> -	if (!capable(CAP_NET_ADMIN))
>> +	if (!ns_capable(current->nsproxy->net_ns->user_ns, CAP_NET_ADMIN))
>> 		return -EPERM;
>=20
> Shouldn't this be a ns_capable(net->user_ns, =A1=AD?
> Otherwise an user can create a new user_ns followed by a new net_ns a=
nd has
> CAP_NET_ADMIN. We need to check whether he is allowed in the user_ns =
of the
> net_ns which belongs to the ppp net device which you want to open.
You are totally right. However, I wonder how can i get the =A1=B0net=A1=
=B1 struct when=20
opening /dev/ppp
>=20
> Thanks,
> //richard
