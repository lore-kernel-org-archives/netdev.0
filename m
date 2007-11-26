From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: [PATCH 12/21] r8169: confusion between hardware and IP header
	alignment
Date: Mon, 26 Nov 2007 23:42:01 +0100
Message-ID: <20071126224201.GA13934@electric-eye.fr.zoreil.com>
References: <20070629201212.GA3240@electric-eye.fr.zoreil.com> <20070629202555.GN3240@electric-eye.fr.zoreil.com> <20071123074549.GE18081@deprecation.cyrius.com> <20071125230524.GC21363@electric-eye.fr.zoreil.com> <20071126083613.GL20922@deprecation.cyrius.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Edward Hsu <edward_hsu@realtek.com.tw>,
	bunk@stusta.de
To: Martin Michlmayr <tbm@cyrius.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from electric-eye.fr.zoreil.com ([213.41.134.224]:43838 "EHLO
	electric-eye.fr.zoreil.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753341AbXKZWqr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Nov 2007 17:46:47 -0500
Content-Disposition: inline
In-Reply-To: <20071126083613.GL20922@deprecation.cyrius.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Martin Michlmayr <tbm@cyrius.com> :
> * Francois Romieu <romieu@fr.zoreil.com> [2007-11-26 00:05]:
> > > I'd like to backport the fix to the 2.6.18 kernel that is in our
> > > stable release and have a couple of questions:
> > >  - Does your later patch "align the IP header when there is no DM=
A
> > >    constraint" fix any bugs or is it merely an improvement?
> > It fixes a "it was faster before" problem.
>=20
> Before the patch I'm interested in backporting, right?  In that case,
> the patch I suggested would fix a bug but also introduce a performanc=
e
> regression.  So maybe the later patch should also be backported.  Wha=
t
> do you think?

The regression was due to cc9f022d97d08e4e36d38661857991fe91447d68.
cc9f022d.. does not appear to be in v2.6.18.8.

[...]
> > >  - Should I change "align" to 8 for RTL_CFG_1, as it's done in
> > >    current kernels?
> > No. RTL_CFG_1 is for the 8168 (slightly different beast).
>=20
> Yes, but might 8168 users face similar problems as the one I saw?

Clearly.

There is a pentachi=E9e* of patches to handle correctly the different
flavors of 8168 devices in the recent kernels (not speaking for the
genuine bugs). Until someone analyzes the log of the r8169, extracts
the relevant pieces and tests them with 2.6.18.x, it will be hard to
claim to support the 8168 with this kernel.

[*] en fran=E7ais dans le texte.

>=20
> > If you have 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2 applied, you
> > want c946b3047205d7e107be16885bbb42ab9f10350a too.
> ...
> > If you move from the 8110SB to the 8110SC, you will probably want t=
o apply
> > 65d916d95314566f426cc40ff0f17b754a773b0b
>=20
> I don't have 6dccd16b7c2703e8bbf8bca62b5cf248332afbe2 and it still
> says 8110SB, so I won't need these patches for my device.  However,
> these patches look like candidates to put into 2.6.18 anyway.  I'd
> like to avoid backporting too many changes from 2.6.24 to 2.6.18, but
> are there any fixes we should absolutely have?

Let aside the "align" fixes, the short list below contains some candida=
tes
in reverse order:

315917d23fdd20a0f4ff99b9228de5840d9d276c
9cb427b6ff0b3e235c518acf5c1fcbbfc95f0ae2
d03902b8864d7814c938f67befade5a3bba68708 | you should already have thos=
e
a27993f3d9daca0dffa26577a83822db99c952e2 |
eb2a021c4710b98081daa797d5a729ac23c240cd
2efa53f373ed811d4860904f5205b8a3b376e253
99f252b097a3bd6280047ba2175b605671da4a23
1371fa6db0bbb8e23f988a641f5ae7361bc629dd

It's gross though: there are 99 changes from v2.6.18.8 to current maste=
r
for the r8169 driver and some registers init changes may have been part=
ially
reverted later.

Sorry if it is not terribly specific but I really, really, really need =
to
spend more time on several bugs first.

[...]
> With 2.6.24-rc2-g8c086340-dirty:
> r8169 Gigabit Ethernet driver 2.2LK loaded
> eth0: RTL8169sb/8110sb at 0xe085c200, 00:14:fd:10:33:8e, XID 10000000=
 IRQ 27
> r8169 Gigabit Ethernet driver 2.2LK loaded
> eth1: RTL8169sb/8110sb at 0xe085e300, 00:14:fd:10:33:8f, XID 10000000=
 IRQ 30

Nice. Thanks.

--=20
Ueimor
