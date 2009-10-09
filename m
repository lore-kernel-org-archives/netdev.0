From: =?iso-8859-1?Q?Sjur_Br=E6ndeland?= <sjur.brandeland@stericsson.com>
Subject: RE: [7/8,RFC] CAIF Protocol Stack
Date: Fri, 9 Oct 2009 14:37:43 +0200
Message-ID: <61D8D34BB13CFE408D154529C120E07902ED7054@eseldmw101.eemea.ericsson.se>
References: <1253727096-10413-1-git-send-email-sjur.brandeland@stericsson.com> <4ACA1D31.6000008@babic.homelinux.org> <61D8D34BB13CFE408D154529C120E07902ED671E@eseldmw101.eemea.ericsson.se> <4ACDF12A.6030906@babic.homelinux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	"Kim Lilliestierna XX" <kim.xx.lilliestierna@stericsson.com>
To: "Stefano Babic" <stefano.babic@babic.homelinux.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailgw5.ericsson.se ([193.180.251.36]:55670 "EHLO
	mailgw5.ericsson.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755407AbZJIMiX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 9 Oct 2009 08:38:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <4ACDF12A.6030906@babic.homelinux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Stefano.
Thank you very much for looking into this!
I find this as very valuable feedback.

Stefano Babic wrote:
> I discovered there is a production bug in the Makefile and the setup
> of the extract function in cfcnfg_get_packet_funcs() is inconsistent.=
=20
> Indeed, I traced the address of the extract function and I can find
> that the address does not point to cfpkt_extract(), as I assumed.=20
>=20
> The problem is due to the usage of the define CAIF_USE_SKB. This is
> used in caif_layer.h, but some files (net/caif/*) are compiled with
> the macro defined, while the drivers (drivers/net/caif/*) not. =20
> Rather I did not get an "oops", because a valid pointer was
> set....but to the wrong function !=20
> I have also seen that CAIF_USE_SKB is not used in
> cfpkt_get_packet_funcs, and this generates a problem if CAIF_USE_SKB
> is not set, because the "fromnative" and "tonative" functions are
> always set, even if they do not belong to the structure.  =20

Well done finding this! I have corrected this as suggested in the new p=
atch-set.

>=20
> IMHO should be possible to get rid of the usage of CAIF_USE_SKB in
> the structure definition (in caif_layer.h) and to provide always the
> same structure definition in both case. I would prefer to set the
> values of cfpkt_fromnative and cfpkt_tonative to NULL, instead of
> reducing the size of the structure.   =20

Agree, and done.
>=20
> I am not sure I understood the meaning of using this structure,
> because at the moment the setup is fixed and I cannot find any point
> in code where the structure is assigned to another set of functions.
> Probably you arrange to have multiple choices in future, I can
> suppose.   =20
>=20

The choices are decided compile time from Kconfig.

> What about to pass directly the pointer to the structure instead of
> copying returning its value ? It seems not necessary to me, I changed
> cfpkt_get_packet_funcs in this direction. =20

I haven't done this yet, but it seems reasonable.

>=20
> Meanwhile, it seems some bytes are sent now to the physical interface=
=2E
>=20
> <caif_chropen:797, TRACE> [caif_chropen:797] WAIT FOR CONNECT
> RESPONSE <caif_chropen:820, TRACE> caif_open: connect timed out=20
>=20
> However, I get no connection, but probably this is another problem...=
=2E
>=20

Do you have a (ST-)Ericsson modem talking CAIF connected?
The correct behavior is to wait for the CONNECT_RESPONSE, and time out.

BR/Sjur Br=E6ndeland
