From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute2 tools for 2.6.31
Date: Fri, 11 Sep 2009 09:51:07 +0200
Message-ID: <4AAA016B.2000003@gmail.com>
References: <20090910120416.6fd03d1f@s6510> <4AAA00B7.9030904@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Stephen Hemminger <shemminger@vyatta.com>, netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:48397 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754065AbZIKHvF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Sep 2009 03:51:05 -0400
In-Reply-To: <4AAA00B7.9030904@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Stephen Hemminger a =E9crit :
>> I am putting together release for 2.6.31 based tools.
>> The only open issue is how to deal with the error handling in comman=
ds
>> that do monitoring filtering.  Right now leaning towards the two soc=
ket
>> solution.
>>
>> So if you have anything else that you have been waiting for,
>> please drop me a note.
>>
>=20
> One thing that is IMHO strange is the output of sk information=20
> on 64 bits (x86_64 for example)
>=20
> # ss -e dst 55.225.18.6
> State      Recv-Q Send-Q                                Local Address=
:Port                                    Peer Address:Port
> ESTAB      0      0                                      55.225.18.96=
:9273                                     55.225.18.6:37405    timer:(k=
eepalive,20min,0) ino:57807651 sk:36e40c80ffff8100
>=20
> True sk pointer is ffff8100ffff8100, not 36e40c80ffff8100
>=20

Oops I meant ffff810036e40c80, sorry for the copy/paste error ;)

>=20
>=20
> ss/misc.c
>=20
>                 printf(" sk:%08x", r->id.idiag_cookie[0]);
>                 if (r->id.idiag_cookie[1] !=3D 0)
>                         printf("%08x", r->id.idiag_cookie[1]);
>=20
> while kernel does :
>         r->id.idiag_cookie[0] =3D (u32)(unsigned long)sk;
>         r->id.idiag_cookie[1] =3D (u32)(((unsigned long)sk >> 31) >> =
1);
>=20
>=20
>=20
> What do you think of following patch ?
>=20
> [PATCH] ss: correct display of sk pointer
>=20
> On 64bit arches, sk pointer was 32/32 reversed.
>=20
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>=20
> diff --git a/misc/ss.c b/misc/ss.c
> index 651fe3b..2447186 100644
> --- a/misc/ss.c
> +++ b/misc/ss.c
> @@ -1393,9 +1393,10 @@ static int tcp_show_sock(struct nlmsghdr *nlh,=
 struct filter *f)
>  		if (r->idiag_uid)
>  			printf(" uid:%u", (unsigned)r->idiag_uid);
>  		printf(" ino:%u", r->idiag_inode);
> -		printf(" sk:%08x", r->id.idiag_cookie[0]);
> +		printf(" sk:");
>  		if (r->id.idiag_cookie[1] !=3D 0)
>  			printf("%08x", r->id.idiag_cookie[1]);
> + 		printf("%08x", r->id.idiag_cookie[0]);
>  	}
>  	if (show_mem || show_tcpinfo) {
>  		printf("\n\t");
>=20
>=20
