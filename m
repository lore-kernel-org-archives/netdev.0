From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH] iproute2: support xfrm upper protocol gre key
Date: Tue, 23 Nov 2010 22:26:47 +0000
Message-ID: <1290551207.3013.9.camel@localhost>
References: <1290524559-22086-1-git-send-email-timo.teras@iki.fi>
	 <20101123082404.5b8ad019@nehalam> <4CEBEF7C.2060806@iki.fi>
	 <20101123101302.54a9e4be@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Timo =?ISO-8859-1?Q?Ter=E4s?= <timo.teras@iki.fi>,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.solarflare.com ([216.237.3.220]:5590 "EHLO
	exchange.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752575Ab0KWW0x convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 23 Nov 2010 17:26:53 -0500
In-Reply-To: <20101123101302.54a9e4be@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-11-23 at 10:13 -0800, Stephen Hemminger wrote:
> On Tue, 23 Nov 2010 18:44:44 +0200
> Timo Ter=C3=A4s <timo.teras@iki.fi> wrote:
>=20
> > On 11/23/2010 06:24 PM, Stephen Hemminger wrote:
> > > On Tue, 23 Nov 2010 17:02:39 +0200
> > > Timo Ter=C3=A4s <timo.teras@iki.fi> wrote:
> > >=20
> > >> +	case IPPROTO_GRE:
> > >> +		if (sel->sport_mask || sel->dport_mask) {
> > >> +			struct in_addr key;
> > >> +			key.s_addr =3D htonl((ntohs(sel->sport) << 16) + ntohs(sel->=
dport));
> > >> +			inet_ntop(AF_INET, &key, abuf, sizeof(abuf));
> > >> +			fprintf(fp, "key %s ", abuf);
> > >> +		}
> > >=20
> > > The GRE key is not really an IPv4 address. Why should the utiliti=
es
> > > use IPv4 address manipulation to format/scan it.  It makes more s=
ense
> > > to me to just use u32 an do the necessary ntohl.
> >=20
> > This is pretty much how iptunnel.c does it, so I copied the code. W=
ould
> > you prefer to format it as single u32 number? Or use something else=
 for
> > formatting it similar to IPv4?
> >=20
> > In either case, we should change iptunnel.c to match ipxfrm.c. It'l=
l be
> > easier if both parts handling the gre key treat it equivalently.
> >=20
> > I think Cisco does indeed treat it as u32 number in the configurati=
ons.
> > So I'm okay updating this patch, and fixing iptunnel.c side too. We
> > might still want to keep the parsing of ipv4 format to keep backwar=
ds
> > compatibility.
>=20
> My preference would be to take both dotted quad and a single
> number.

inet_aton() covers that.

Ben.

--=20
Ben Hutchings, Senior Software Engineer, Solarflare Communications
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.

