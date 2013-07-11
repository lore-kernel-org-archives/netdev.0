From: "Cedric Debarge" <cedric.debarge@acksys.fr>
Subject: [RFC]: vlan priority handling in WMM
Date: Thu, 11 Jul 2013 09:45:00 +0200
Message-ID: <773DB8A82AB6A046AE0195C68612A319015E05AD@sbs2003.acksys.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <linux-wireless@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out03.msg.oleane.net ([62.161.7.1]:44895 "EHLO
	smtp-out03.msg.oleane.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755342Ab3GKI1m convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Jul 2013 04:27:42 -0400
Content-class: urn:content-classes:message
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear mailing list,

I would like to manage the VLAN priority in Wireless QOS (WMM).

I get the VLAN tag from skb->vlan_tci and I extract the VLAN priority.=20

How I should handle the priority value 0.=20
	- Handle this value as no priority request, In this case the frame wil=
l=20
		sent with the DSCP priority or default (Best effort)
	- Handle this value as a lowest priority, in this case I Map it to the=
 WMM.

=46or your information, you can found below a discussion on this point=20
with Johannes Berg.

Regards.

Cedric Voncken.

-----Message d'origine-----
De : Johannes Berg [mailto:johannes@sipsolutions.net]
Envoy=E9 : lundi 8 juillet 2013 14:16
=C0 : voncken
Cc : linux-wireless@vger.kernel.org
Objet : Re: [PATCH V2] vlan priority handling in WMM

On Mon, 2013-07-08 at 12:39 +0200, voncken wrote:
> > > The vlan Tag contain three bit for priority. The value 0 indicate
> no
> > > priority (on this case the VLAN tag contain only VID). The
> vlan_tci
> > > field is set to zero if the frame do not contain the vlan tag. So
> if
> > > we have not a vlan tag or no priority in VLAN tag the priority
> value
> > > is always 0.
>=20
> > Yes but don't we know that the vlan_tci field is valid?
>=20
> > I don't think you're correct in that 0 means "no priority present",
> it actually means "best effort" as far as I can tell. Ignoring the=20
> VLAN tag when the field is 0 would mean we could use a higher priorit=
y=20
> from the contents of the frame, which would not be desired?
>=20
> I can add a test with the macro vlan_tx_tag_present() to verify if th=
e=20
> vlan_tci field is valid.
> I test the value 0 to skip the VLAN priority and use the dscp priorit=
y=20
> in this case. The priority 0 in VLAN tag is often use to turn off the=
=20
> QOS, because not bit is allowed for it.

What do you mean by "is often used"? I don't see how that would be the =
case? Are you saying routers commonly ignore the VLAN priority value if=
 it's 0? That would seem odd?

> For me is it correct. Nevertheless, if you prefer, I can test only th=
e=20
> vlan_tci validity and in this case always use the VLAN priority.

I don't know! Since you don't seem to really know either, we should ask=
 somebody who knows, I think. Maybe you should Cc netdev with this ques=
tion on the patch or so?

> Sorry I made a mistake  0xE000 >>13 =3D 0x0007 and not 0x0003, and 7 =
is=20
> a 3 bits value.

Ah yes, I made the same mistake, sorry.

johannes
