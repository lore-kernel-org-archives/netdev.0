From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: Re: switchdev and VLAN ranges
Date: Sun, 11 Oct 2015 18:41:25 -0400
Message-ID: <20151011224125.GB21128@ketchup.lan>
References: <493168159.229458.1444433451493.JavaMail.zimbra@savoirfairelinux.com>
 <BF3B1B92-E7B5-4C49-9B56-FBD36E546F28@mellanox.com>
 <5618EA2A.3020900@cumulusnetworks.com>
 <20151011071208.GA2188@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>,
	Elad Raz <eladr@mellanox.com>,
	Scott Feldman <sfeldma@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	Ido Schimmel <idosch@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:55868 "EHLO
	mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752349AbbJKWl3 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2015 18:41:29 -0400
Content-Disposition: inline
In-Reply-To: <20151011071208.GA2188@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Oct. Sunday 11 (41) 09:12 AM, Jiri Pirko wrote:
> Sat, Oct 10, 2015 at 12:36:26PM CEST, nikolay@cumulusnetworks.com wro=
te:
> >On 10/10/2015 09:49 AM, Elad Raz wrote:
> >>=20
> >>> On Oct 10, 2015, at 2:30 AM, Vivien Didelot <vivien.didelot@savoi=
rfairelinux.com> wrote:
> >>>
> >>> I have two concerns in mind:
> >>>
> >>> a) if we imagine that drivers like Rocker allocate memory in the =
prepare
> >>> phase for each VID, preparing a range like 100-4000 would definit=
ely not
> >>> be recommended.
> >>>
> >>> b) imagine that you have two Linux bridges on a switch, one using=
 the
> >>> hardware VLAN 100. If you request the VLAN range 99-101 for the o=
ther
> >>> bridge members, it is not possible for the driver to say "I can
> >>> accelerate VLAN 99 and 101, but not 100". It must return OPNOTSUP=
P for
> >>> the whole range.
> >>=20
> >> Another concern I have with vid_being..vid_end range is the =E2=80=
=9Cflags=E2=80=9D. Where flags can be BRIDGE_VLAN_INFO_PVID.
> >> There is no sense having more than one VLAN as a PVID.
> >> This leave the HW vendor the choice which VLAN id they will use as=
 the PVID.
> >>=20
> >
> >iproute2 doesn't allow to do it but I can see that someone can actua=
lly make it
> >so the flags for the range have it and it doesn't look correct. Perh=
aps we need
> >something like the patch below to enforce this from kernel-side.
> >
> >
> >diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
> >index d78b4429505a..02b17b53e9a6 100644
> >--- a/net/bridge/br_netlink.c
> >+++ b/net/bridge/br_netlink.c
> >@@ -524,6 +524,9 @@ static int br_afspec(struct net_bridge *br,
> > 			if (vinfo_start)
> > 				return -EINVAL;
> > 			vinfo_start =3D vinfo;
> >+			/* don't allow range of pvids */
> >+			if (vinfo_start->flags & BRIDGE_VLAN_INFO_PVID)
> >+				return -EINVAL;
> > 			continue;
> > 		}
> >=20
>=20
> Looks correct to me. Could you please submit this properly? Thanks!

The above patch is correct, but we only solve part of the problem, sinc=
e
the range and bridge flags are exposed by switchdev_obj_port_vlan as is=
=2E

Thanks,
-v
