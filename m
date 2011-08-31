From: Michal Schmidt <mschmidt@redhat.com>
Subject: Re: [PATCH 7/7] bnx2x: expose HW RX VLAN stripping toggle
Date: Wed, 31 Aug 2011 15:53:24 +0200
Message-ID: <20110831155324.7554d035@alice>
References: <1314714646-3642-1-git-send-email-mschmidt@redhat.com>
	<CAHXqBFLgTHvxL34eR1qX7nEmntyOBXYrg-7LQvW=d8dnDpbhWg@mail.gmail.com>
	<4E5D3A43.1060202@redhat.com>
	<201108311501.39936.vladz@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?TWljaGHFgiBNaXJvc8WCYXc=?= <mirqus@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Dmitry Kravkov" <dmitry@broadcom.com>,
	"Eilon Greenstein" <eilong@broadcom.com>
To: "Vlad Zolotarov" <vladz@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9466 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750779Ab1HaNx2 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Aug 2011 09:53:28 -0400
In-Reply-To: <201108311501.39936.vladz@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 31 Aug 2011 15:01:39 +0300 Vlad Zolotarov wrote:
> On Tuesday 30 August 2011 22:30:11 Michal Schmidt wrote:
>=20
> > > and then also in fp->flags.  Are the
> > > fp->flags strictly mirroring hardware state (as in: there is no
> > > way the states can differ in any point in time where the flags ar=
e
> > > tested)?
> >=20
> > Yes. This is the purpose of the second mirroring of the flag.
>=20
> Michal,
> although the above is true i'd say it's a bit of an overkill:
> RX VLAN stripping is configured in a function level, so keeping it in
> a per queue level is not needed.=20
>=20
> The problem u were trying to resolve (and u resolved it) was to
> separate the RX_VLAN_ENABLED flag semantics into two: requested
> feature and HW configured feature in order to further check the
> second in the fast path, while setting the first one in the
> set_features(). Then the second lag is updated according to the first
> one during the loading of the function (bnx2x_nic_load()).
>=20
> Therefore it would be enough to just add those two flags in the
> function (bp) level keeping the rest of your patch as it is. This
> would also cancel the need for a patch 6.

Alright, I will remove the per-fp flag and move it to bp.

I will also apply the cheat suggested by Micha=C5=82, so that:
 - dev->features & NETIF_F_HW_VLAN_RX is the requested state
 - bp->flags & RX_VLAN_STRIP_FLAG is the HW configured state
=3D> Only one new bp flag needed, not two.

BTW, Micha=C5=82's cheat should apply to TPA_ENABLE_FLAG as well - it o=
nly
mirrors NETIF_F_LRO. But for TPA the HW configured state is really
per-queue (fp->disable_tpa). I will remove TPA_ENABLE_FLAG unless you
object to Micha=C5=82's "cheat".

Thanks,
Michal
