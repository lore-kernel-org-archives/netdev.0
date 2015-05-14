From: Wolfgang Walter <linux@stwm.de>
Subject: Re: kernel >= 4.0: crashes when using traceroute6 with isatap
Date: Thu, 14 May 2015 02:32:24 +0200
Message-ID: <1460179.Gl6yCv4mQ9@h2o.as.studentenwerk.mhn.de>
References: <1770409.aMESoOv08f@h2o.as.studentenwerk.mhn.de> <1489362.AtetvSCXN1@h2o.as.studentenwerk.mhn.de> <5552602E.3060300@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dresden.studentenwerk.mhn.de ([141.84.225.229]:45866 "EHLO
	email.studentenwerk.mhn.de" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754092AbbENAc0 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 May 2015 20:32:26 -0400
In-Reply-To: <5552602E.3060300@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am Dienstag, 12. Mai 2015, 16:18:54 schrieb Vlad Yasevich:
> On 05/06/2015 06:11 PM, Wolfgang Walter wrote:
> > Am Mittwoch, 6. Mai 2015, 11:15:18 schrieben Sie:
> >> (Cc'ing netdev.)
> >>=20
> >> On Sat, May 2, 2015 at 5:29 AM, Wolfgang Walter <linux@stwm.de> wr=
ote:
> >>> Am Samstag, 2. Mai 2015, 02:16:36 schrieb Wolfgang Walter:
> >>>> Hello,
> >>>>=20
> >>>> kernel 4.0 (and 4.0.1) crashes immediately when I use traceroute=
6 with
> >>>> an
> >>>> isatap-tunnel.
> >>>=20
> >>> I did some further tests. To trigger the crash you need
> >>>=20
> >>> * isatap-tunnel (probably any sit-tunnel will do it)
> >>> * raw-socket
> >>> * udp
> >>>=20
> >>> Using icmpv6 or tcp i.e. does not trigger it.
> >>=20
> >> Do you have a script to reproduce it?
> >>=20
> >>=20
> >> Thanks for the bug report!
> >=20
> > You need a isatap-server with say ipv4-address $X
> >=20
> > Then, on host with 4.0, start isatapd: isatapd --mtu 1280 $X
> >=20
> > then do
> >=20
> > 	traceroute6 www.google.de
> >=20
> > Regards,
>=20
> Hi Walter
>=20
> Could you try this patch.  Looks like raw passes transhdrlen
> of 0 on the first packet and that makes IPv4 behave correctly,
> but not IPv6.
>=20
>=20
> diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
> index 7fde1f2..fd9c079 100644
> --- a/net/ipv6/ip6_output.c
> +++ b/net/ipv6/ip6_output.c
> @@ -1278,7 +1278,7 @@ emsgsize:
>  	/* If this is the first and only packet and device
>  	 * supports checksum offloading, let's use it.
>  	 */
> -	if (!skb && sk->sk_protocol =3D=3D IPPROTO_UDP &&
> +	if (transhdrlen && sk->sk_protocol =3D=3D IPPROTO_UDP &&
>  	    length + fragheaderlen < mtu &&
>  	    rt->dst.dev->features & NETIF_F_V6_CSUM &&
>  	    !exthdrlen)

Ok, that works as fix. No crash and checksums are ok.

Regards,
--=20
Wolfgang Walter
Studentenwerk M=FCnchen
Anstalt des =F6ffentlichen Rechts
