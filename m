From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 08:37:20 +0100
Message-ID: <4AE7F4B0.4010007@gmail.com>
References: <4AE77F64.3090302@candelatech.com> <20091027162434.6dc31b2d@nehalam> <4AE78297.9000909@candelatech.com> <4AE7EC65.8000600@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:33513 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757462AbZJ1HhT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2009 03:37:19 -0400
In-Reply-To: <4AE7EC65.8000600@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet a =E9crit :
> Ben Greear a =E9crit :
>> Probably the right way is to give a cmd-line arg to set the buffer s=
ize
>> and also continue if the error is ENOBUFs (but print some error out
>> so users know they have issues).  I can make the attempt if that
>> sounds good to you.
>=20
> Real fix is to realloc buffer at receive time, no need for user setti=
ng.
>=20
> In my testings I saw it reaching 1 Mbyte
> write(2, "REALLOC buflen 8192\n"..., 20) =3D 20
> write(2, "REALLOC buflen 16384\n"..., 21) =3D 21
> write(2, "REALLOC buflen 32768\n"..., 21) =3D 21
> write(2, "REALLOC buflen 65536\n"..., 21) =3D 21
> write(2, "REALLOC buflen 131072\n"..., 22) =3D 22
> write(2, "REALLOC buflen 262144\n"..., 22) =3D 22
> write(2, "REALLOC buflen 524288\n"..., 22) =3D 22
>=20
>=20
> [iproute2] realloc buffer in rtnl_listen
>=20
> # ip monitor route
> netlink receive error No buffer space available (105)
> Dump terminated=20
>=20
> Reported-by: Ben Greear<greearb@candelatech.com>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Oops, this was wrong, Ben was right, sorry...

ENOBUFS errors is a flag to actually report to user that some informati=
on was dropped,
not that user supplied buffer at recv() time is not big enough.

I was surprised that buffer could reach 1Mbytes, while RCVBUF was 32768=
 or so.


