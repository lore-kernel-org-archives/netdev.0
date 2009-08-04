From: Badalian Vyacheslav <slavon@bigtelecom.ru>
Subject: Re: [PATCH] net: Keep interface binding when sending packets with
 	ipi_ifindex = 0
Date: Tue, 04 Aug 2009 11:57:46 +0400
Message-ID: <4A77E9FA.7030503@bigtelecom.ru>
References: <6c039e090907231439t1def08a4n10978733bee55bec@mail.gmail.com>	 <20090727144402.513369f1.akpm@linux-foundation.org>	 <1248912621.13447.12.camel@merlyn>	 <20090803.212323.256579233.davem@davemloft.net> <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, john.dykstra1@gmail.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: =?UTF-8?B?IkNoaWEtY2hpIFllaCAo6JGJ5a626b2KKSI=?=
	<chiachi@android.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.bigtelecom.ru ([87.255.0.61]:42472 "EHLO
	mail.bigtelecom.ru" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbZHDH5s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Aug 2009 03:57:48 -0400
In-Reply-To: <6c039e090908040036j38666152y2db1d4c55529eaff@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chia-chi Yeh (=E8=91=89=E5=AE=B6=E9=BD=8A) =D0=BF=D0=B8=D1=88=D0=B5=D1=82=
:
> After thinking more deeply, I believe that IPv6 does the right thing
> and IPv4 does not. SO_BINDTODEVICE requires CAP_NET_RAW, so it is a
> privileged operation. Therefore, it looks weird to me if one can
> specify other interface than the bound one without the same
> capability. The following patch makes the behavior in IPv4 and IPv6
> identical. Thanks for your help.
>=20
> Chia-chi
>=20
> --- a/net/ipv4/ip_sockglue.c    2009-08-04 15:11:39.000000000 +0800
> +++ b/net/ipv4/ip_sockglue.c    2009-08-04 15:17:05.000000000 +0800
> @@ -213,7 +213,11 @@
>                         if (cmsg->cmsg_len !=3D CMSG_LEN(sizeof(struc=
t
> in_pktinfo)))
>                                 return -EINVAL;
>                         info =3D (struct in_pktinfo *)CMSG_DATA(cmsg)=
;
> -                       ipc->oif =3D info->ipi_ifindex;
> +                       if (info->ipi_ifindex) {
> +                               if (ipc->oif && info->ipi_ifindex !=3D=
 ipc->oif)
> +                                       return -EINVAL;
> +                               ipc->oif =3D info->ipi_ifindex;

Hello
Sorry if its my mistake or i someone not understand :)

if (ipc->oif && info->ipi_ifindex !=3D ipc->oif)
	// if match: info->ipi_ifindex !=3D ipc->oif
	return ...
else
	// else match: info->ipi_ifindex =3D=3D ipc->oif
	// but you do=20
	ipc->oif =3D info->ipi_ifindex;=20
	// why if you else match allready check for it?

Thanks



> +                       }
>                         ipc->addr =3D info->ipi_spec_dst.s_addr;
>                         break;
>                 }
>=20
> On Tue, Aug 4, 2009 at 12:23 PM, David Miller<davem@davemloft.net> wr=
ote:
>> From: John Dykstra <john.dykstra1@gmail.com>
>> Date: Wed, 29 Jul 2009 19:10:21 -0500
>>
>>> I guess Dave's letting this stand.  I'm posting this just to make s=
ure
>>> this is an explicit decision.
>> I'm still thinking about this.
>>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
>=20

