From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCHv3] IPv4 TCP fails to send window scale option when window
 scale is zero
Date: Thu, 01 Oct 2009 19:20:33 +0200
Message-ID: <4AC4E4E1.5010300@gmail.com>
References: <1254413613.665110.11357.nullmailer@tron.codefidence.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, ori@comsleep.com, ilpo.jarvinen@helsinki.fi
To: Gilad Ben-Yossef <gilad@codefidence.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:41481 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbZJARUj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 13:20:39 -0400
In-Reply-To: <1254413613.665110.11357.nullmailer@tron.codefidence.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gilad Ben-Yossef a =E9crit :
> From: Ori Finkelman <ori@comsleep.com>
>=20
> Acknowledge TCP window scale support by inserting the proper option i=
n SYN/ACK=20
> and SYN headers even if our window scale is zero.
>=20
> This fixes the following observed behavior:
>=20
> 1. Client sends a SYN with TCP window scaling option and non zero win=
dow scale=20
> value to a Linux box.
> 2. Linux box notes large receive window from client.
> 3. Linux decides on a zero value of window scale for its part.
> 4. Due to compare against requested window scale size option, Linux d=
oes not to
>  send windows scale TCP option header on SYN/ACK at all.
>=20
> With the following result:
>=20
> Client box thinks TCP window scaling is not supported, since SYN/ACK =
had no=20
> TCP window scale option, while Linux thinks that TCP window scaling i=
s=20
> supported (and scale might be non zero), since SYN had  TCP window sc=
ale=20
> option and we have a mismatched idea between the client and server=20
> regarding window sizes.
>=20
> Probably it also fixes up the following bug (not observed in practice=
):
>=20
> 1. Linux box opens TCP connection to some server.
> 2. Linux decides on zero value of window scale.
> 3. Due to compare against computed window scale size option, Linux do=
es=20
> not to set windows scale TCP  option header on SYN.=20
>=20
> With the expected result that the server OS does not use window scale=
 option=20
> due to not receiving such an option in the SYN headers, leading to su=
boptimal=20
> performance.
>=20
> Signed-off-by: Gilad Ben-Yossef <gilad@codefidence.com>
> Signed-off-by: Ori Finkelman <ori@comsleep.com>

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Note, to reproduce the wscale set to 0 on active connections,
you have to play with /proc/sys/net settings :

echo 65535 >/proc/sys/net/core/rmem_max
echo "4096 16384 32768" >/proc/sys/net/ipv4/tcp_rmem

-> wscale 0 -> SYN packet without WSCALE option (on non patched kernels=
)

