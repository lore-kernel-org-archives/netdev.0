From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 10:13:02 -0800
Message-ID: <20101123101302.54a9e4be@nehalam>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
	<20101123082404.5b8ad019@nehalam>
	<4CEBEF7C.2060806@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Timo =?ISO-8859-1?B?VGVy5HM=?= <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:44371 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756005Ab0KWSNX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Nov 2010 13:13:23 -0500
In-Reply-To: <4CEBEF7C.2060806@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 23 Nov 2010 18:44:44 +0200
Timo Ter=E4s <timo.teras@iki.fi> wrote:

> On 11/23/2010 06:24 PM, Stephen Hemminger wrote:
> > On Tue, 23 Nov 2010 17:02:39 +0200
> > Timo Ter=E4s <timo.teras@iki.fi> wrote:
> >=20
> >> +	case IPPROTO_GRE:
> >> +		if (sel->sport_mask || sel->dport_mask) {
> >> +			struct in_addr key;
> >> +			key.s_addr =3D htonl((ntohs(sel->sport) << 16) + ntohs(sel->dp=
ort));
> >> +			inet_ntop(AF_INET, &key, abuf, sizeof(abuf));
> >> +			fprintf(fp, "key %s ", abuf);
> >> +		}
> >=20
> > The GRE key is not really an IPv4 address. Why should the utilities
> > use IPv4 address manipulation to format/scan it.  It makes more sen=
se
> > to me to just use u32 an do the necessary ntohl.
>=20
> This is pretty much how iptunnel.c does it, so I copied the code. Wou=
ld
> you prefer to format it as single u32 number? Or use something else f=
or
> formatting it similar to IPv4?
>=20
> In either case, we should change iptunnel.c to match ipxfrm.c. It'll =
be
> easier if both parts handling the gre key treat it equivalently.
>=20
> I think Cisco does indeed treat it as u32 number in the configuration=
s.
> So I'm okay updating this patch, and fixing iptunnel.c side too. We
> might still want to keep the parsing of ipv4 format to keep backwards
> compatibility.

My preference would be to take both dotted quad and a single
number.


--=20
