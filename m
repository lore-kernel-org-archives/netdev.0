From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: TCP port randomization
Date: Wed, 17 Oct 2007 15:34:12 -0700
Message-ID: <20071017153412.6ef040bf@freepuppy.rosehill>
References: <Pine.LNX.4.64.0710172308140.12701@bizon.gios.gov.pl>
	<20071017150818.0e878846@freepuppy.rosehill>
	<Pine.LNX.4.64.0710180026020.12701@bizon.gios.gov.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51718 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756998AbXJQWef convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 17 Oct 2007 18:34:35 -0400
In-Reply-To: <Pine.LNX.4.64.0710180026020.12701@bizon.gios.gov.pl>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 18 Oct 2007 00:31:13 +0200 (CEST)
Krzysztof Oledzki <olel@ans.pl> wrote:

>=20
>=20
> On Wed, 17 Oct 2007, Stephen Hemminger wrote:
>=20
> > On Wed, 17 Oct 2007 23:15:48 +0200 (CEST)
> > Krzysztof Oledzki <olel@ans.pl> wrote:
> >
> >> Hello,
> >>
> >> Is it normal that TCP port randomization (tested with 2.6.22) work=
s only
> >> when explicitly binding to a IP address:
> >>
> >>
> >> --- cut here ---
> >> root@fw1:~# nc 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >> root@fw1:~# nc 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >> root@fw1:~# nc 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >>
> >> 23:11:11.896126 IP 192.168.129.2.37839 > 192.168.129.28.11: S
> >> 23:11:12.146573 IP 192.168.129.2.37840 > 192.168.129.28.11: S
> >> 23:11:12.396488 IP 192.168.129.2.37841 > 192.168.129.28.11: S
> >> --- cut here ---
> >>
> >>
> >> --- cut here ---
> >> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >> root@fw1:~# nc -s 192.168.129.2 192.168.129.28 11
> >> (UNKNOWN) [192.168.129.28] 11 (systat) : Connection refused
> >>
> >> 23:11:31.704391 IP 192.168.129.2.57204 > 192.168.129.28.11: S
> >> 23:11:34.400048 IP 192.168.129.2.14512 > 192.168.129.28.11: S
> >> 23:11:34.606707 IP 192.168.129.2.20117 > 192.168.129.28.11: S
> >> --- cut here ---
> >>
> >> Best regards,
> >>
> >>  				Krzysztof Ol=C4=99dzki
> >
> > It is a expected side effect.
>=20
> So it is not possible to use randomization without binding to a speci=
fic=20
> srcip?
>=20
> > The starting point for the search
> > is based on hash(srcaddr, dstaddr, dstport, secret).
> > You are using same source, dest and port so yes it will stay
> > the same until rekeying occurs.
> > The secret only changes every 5min same as TCP initial sequence num=
ber.
>=20
> If I get it right, even with explicitly selected constant srcaddr por=
t=20
> numbers should simply increase? This is not what I observed.
>=20
>
When you set srcaddr, it calls bind, and bind does randomization always
independent of address.

This existing behavior may seem odd, but it shouldn't present a securit=
y
problem.

--=20
Stephen Hemminger <shemminger@linux-foundation.org>
