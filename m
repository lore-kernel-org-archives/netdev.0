From: Josef Bacik <jbacik@fb.com>
Subject: Re: [PATCH 1/5 net-next] inet: replace ->bind_conflict with
 ->rcv_saddr_equal
Date: Wed, 21 Dec 2016 10:59:54 -0500
Message-ID: <1482335994.24490.13@smtp.office365.com>
References: <1482264424-15439-1-git-send-email-jbacik@fb.com>
        <1482264424-15439-2-git-send-email-jbacik@fb.com>
        <1482333786.2260.10.camel@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: <davem@davemloft.net>, <kraigatgoog@gmail.com>,
        <eric.dumazet@gmail.com>, <tom@herbertland.com>,
        <netdev@vger.kernel.org>, <kernel-team@fb.com>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33160 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S934631AbcLUQAM (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Dec 2016 11:00:12 -0500
In-Reply-To: <1482333786.2260.10.camel@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 21, 2016 at 10:23 AM, Hannes Frederic Sowa=20
<hannes@stressinduktion.org> wrote:
> On Tue, 2016-12-20 at 15:07 -0500, Josef Bacik wrote:
>>  --- a/net/dccp/ipv6.c
>>  +++ b/net/dccp/ipv6.c
>>  @@ -926,7 +926,7 @@ static const struct inet_connection_sock_af_ops=20
>> dccp_ipv6_af_ops =3D {
>>   	.getsockopt	   =3D ipv6_getsockopt,
>>   	.addr2sockaddr	   =3D inet6_csk_addr2sockaddr,
>>   	.sockaddr_len	   =3D sizeof(struct sockaddr_in6),
>>  -	.bind_conflict	   =3D inet6_csk_bind_conflict,
>>  +	.rcv_saddr_equal   =3D ipv6_rcv_saddr_equal,
>>   #ifdef CONFIG_COMPAT
>>   	.compat_setsockopt =3D compat_ipv6_setsockopt,
>>   	.compat_getsockopt =3D compat_ipv6_getsockopt,
>>=20
>=20
> Btw, small nit, you forgot the corresponding changes in
> dccp_ipv6_mapped, thus causing this compiler error:
>=20
> net/dccp/ipv6.c:961:2: error: unknown field =E2=80=98bind_conflict=E2=80=
=99=20
> specified in initializer
>   .bind_conflict    =3D inet6_csk_bind_conflict,
>   ^
> net/dccp/ipv6.c:961:22: error: =E2=80=98inet6_csk_bind_conflict=E2=80=99=20
> undeclared here (not in a function)
>   .bind_conflict    =3D inet6_csk_bind_conflict,
>                       ^~~~~~~~~~~~~~~~~~~~~~~
> scripts/Makefile.build:293: recipe for target 'net/dccp/ipv6.o' failed

Yeah kbuild caught that yesterday and I have it fixed up in my git tree=20
already, thanks,

Josef
=
