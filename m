From: Maz The Northener <mazziesaccount@gmail.com>
Subject: Re: [PATCH] IPv6 - support for NLM_F_* flags at IPv6 routing requests
Date: Thu, 3 Nov 2011 08:55:34 +0200
Message-ID: <CANhJrGMP4AFq4Aw-n7HNkf=GyZg0Mz=2KDH629c0dDufT433=Q@mail.gmail.com>
References: <1320157347.11816.3.camel@lakki>
	<1320217791.12052.12.camel@lakki>
	<20111102092128.3c67c65e@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matti Vaittinen <matti.vaittinen@nsn.com>, davem@davemloft.net,
	netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:34488 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752190Ab1KCGze convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Nov 2011 02:55:34 -0400
Received: by pzk2 with SMTP id 2so2670497pzk.1
        for <netdev@vger.kernel.org>; Wed, 02 Nov 2011 23:55:34 -0700 (PDT)
In-Reply-To: <20111102092128.3c67c65e@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 2, 2011 at 6:21 PM, Stephen Hemminger <shemminger@vyatta.co=
m> wrote:
> On Wed, 02 Nov 2011 09:09:51 +0200
> Matti Vaittinen <matti.vaittinen@nsn.com> wrote:
>

>> +
>> +
>
> Gratuitous unnecessary whitespace added.
>

I will fix the whitespace errors.

>> + =A0 =A0 int allow_create =3D 1;
>> + =A0 =A0 int replace_required =3D 0;
>> +
>> +
>
> Personally, I dislike boolean flag variables, it is often a sign
> of poorly executed logic flow
>
>

I tend to agree to some level. However sometimes well named variables
make following code easier. And I do not claim the logic flow couldn't
be improved, but I'm not the one going to make big changes to FIB
handling. I would probably end up breaking something.

>> =A0 =A0 =A0 __be32 =A0dir =3D 0;
>> =A0 =A0 =A0 __u32 =A0 sernum =3D fib6_new_sernum();
>>
>> =A0 =A0 =A0 RT6_TRACE("fib6_add_1\n");
>>
>> + =A0 =A0 if (NULL !=3D info &&
>> + =A0 =A0 =A0 =A0 NULL !=3D info->nlh &&
>> + =A0 =A0 =A0 =A0 (info->nlh->nlmsg_flags&NLM_F_REPLACE)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 replace_required =3D 1;
>> + =A0 =A0 }
>> + =A0 =A0 if (NULL !=3D info &&
>> + =A0 =A0 =A0 =A0 NULL !=3D info->nlh &&
>> + =A0 =A0 =A0 =A0 !(info->nlh->nlmsg_flags&NLM_F_CREATE)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 allow_create =3D 0;
>> + =A0 =A0 }
>
> I would move the flag calculation out to the caller and keep fib6_add=
_1
> clean.

Can be done, I just didn't want to introduce two more parameters in
function call. But I'll do that.


>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sn =3D fib6_add_1(fn->su=
btree, &rt->rt6i_src.addr,
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 sizeof(struct in6_addr), rt->rt6i_src.plen,
>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 offsetof(struct rt6_info, rt6i_src));
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 offsetof(struct rt6_info, rt6i_src),
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 info);
>>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (-ENOENT =3D=3D PTR_ERR=
(sn)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 err =3D -E=
INVAL;
>
> This is not how to use PTR_ERR; the more common convention is:
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (IS_ERR(sn)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0err =3D PTR_ERR(sn);
> ...

Makes sense.

>
>
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 sn =3D NUL=
L;
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (sn =3D=3D NULL)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto st_=
failure;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> diff -uNr linux-3.1-rc4.orig/net/ipv6/route.c linux-3.1-rc4.new/net/=
ipv6/route.c
>> --- linux-3.1-rc4.orig/net/ipv6/route.c =A0 =A0 =A0 2011-11-01 14:01=
:55.000000000 +0200
>> +++ linux-3.1-rc4.new/net/ipv6/route.c =A0 =A0 =A0 =A02011-10-27 10:=
45:05.000000000 +0300
>> @@ -1223,9 +1223,18 @@
>> =A0 =A0 =A0 if (cfg->fc_metric =3D=3D 0)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 cfg->fc_metric =3D IP6_RT_PRIO_USER;
>>
>> - =A0 =A0 table =3D fib6_new_table(net, cfg->fc_table);
>> + =A0 =A0 err =3D -ENOBUFS;
>> + =A0 =A0 if (NULL !=3D cfg->fc_nlinfo.nlh &&
>> + =A0 =A0 =A0 =A0 !(cfg->fc_nlinfo.nlh->nlmsg_flags&NLM_F_CREATE)) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 table =3D fib6_get_table(net, cfg->fc_tabl=
e);
>> + =A0 =A0 =A0 =A0 =A0 =A0 if (table =3D=3D NULL) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_WARNING "NLM_F=
_CREATE should be specified when creating new rt\n");
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 table =3D fib6_new_table(n=
et, cfg->fc_table);
>> + =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 } else {
>> + =A0 =A0 =A0 =A0 =A0 =A0 table =3D fib6_new_table(net, cfg->fc_tabl=
e);
>> + =A0 =A0 }
>> =A0 =A0 =A0 if (table =3D=3D NULL) {
>> - =A0 =A0 =A0 =A0 =A0 =A0 err =3D -ENOBUFS;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out;
>> =A0 =A0 =A0 }
>
> This could be a separate patch

Allright. I'll break up the patch. Thanks for taking the time to check
this. I'll send new patches soonish.

--Matti Vaittinen.
