From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: Linux IPv6 DAD not full conform to RFC 4862 ?
Date: Wed, 9 Jan 2008 13:57:44 -0500
Message-ID: <20080109185744.GB25106@hmsreliant.think-freely.org>
References: <20080109153656.GA16962@pingi.kke.suse.de> <20080110.013857.37616214.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: kkeil@suse.de, netdev@vger.kernel.org
To: YOSHIFUJI Hideaki / =?utf-8?B?5ZCJ6Jek6Iux5piO?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:2106 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750720AbYAIS6j (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Jan 2008 13:58:39 -0500
Content-Disposition: inline
In-Reply-To: <20080110.013857.37616214.yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Jan 10, 2008 at 01:38:57AM +0900, YOSHIFUJI Hideaki / =E5=90=89=
=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
> In article <20080109153656.GA16962@pingi.kke.suse.de> (at Wed, 9 Jan =
2008 16:36:56 +0100), Karsten Keil <kkeil@suse.de> says:
>=20
> > So I think we should disable the interface now, if DAD fails on a
> > hardware based LLA.
>=20
> I don't want to do this, at least, unconditionally.
>=20
> Options (not exclusive):
>=20
> - we could have "dad_reaction" interface variable and
>  > 1: disable interface
>  =3D 1: disable IPv6
>  < 0: ignore (as we do now)
>=20
I like the flexibility of this solution, but given that the only part o=
f the RFC
that we're missing on at the moment is that we SHOULD disable the inter=
face on
DAD failure for a link-local address, I would think this scheme would b=
e good:

  < 0 : ignore, and del address from interface (current behavior)=20
  =3D 0 : disable interface for dad failure for a link-local address=20
  > 0 : disable interface for dad failure for any address=20

Regards
Neil
=20
> --yoshfuji
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
