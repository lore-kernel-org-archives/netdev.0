From: Dan Williams <dcbw@redhat.com>
Subject: Re: sd8686 linux system hang: not always
Date: Wed, 19 Aug 2009 14:39:57 -0500
Message-ID: <1250710797.5351.89.camel@localhost.localdomain>
References: <20090819185605.GA19345@kaos.fbx.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?Beno=EEt?= Vaillant <benoit.vaillant@no-log.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36205 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750747AbZHSTuv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 19 Aug 2009 15:50:51 -0400
In-Reply-To: <20090819185605.GA19345@kaos.fbx.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2009-08-19 at 20:56 +0200, Beno=C3=AEt Vaillant wrote:
> Hi list,
>=20
> It seems my previous message for libertas-dev didn't make its ways
> through, so resending it... Appologies if it did in any way and for
> multiple receptions if any :/
>=20
> Here are a few notes, to try to isolate the issue(s?) regarding this
> problem.
>=20
> /*
> Just a bit of context information:
> I'm using an MID (quite close to an Aigo, although bios differs,
> probably some hardware too, yet I've not checked much on that). I'm
> trying to use my Marvell card to get wifi access on a debian
> installation. The other OS installed (midinux) successfully gets a
> connection using the 8686_v9 mobilin driver, so I'd not go for any
> hardware issue. This driver failing to compile 'out of the box' on
> fresh kernels, I thought getting the libertas module working would be
> a better way to get through.
> */
>=20
> I had the same kernel hang issue as reported earlier on this list[1]
> and can also confirm the reload issue[2] still seems to be here,
> although I'm not really bothered by that for the moment and didn't
> take any time at assessing it.
>=20
> I did a few attempts at getting associated with an AP, initially
> unsuccessfully getting a hang, my latest attempts leading to a better
> result (no association, yet no hang! :) ).
>=20
> I've tried both 8.73.7.p3 and 9.70.3.p24 versions of the firmware (an=
d
> the one provided by midinux, which I highly suspect to be a mere
> 8.73.7.p3). In my latest attempts, I focused only on the 8.73.7.p3
> since it gave good results using iwlist scannig: I could list the
> available APs fine.
>=20
> Now, with the attempts I did, using a kernel 2.6.31-rc5, I used to
> hang. Using some manually inserted printk()s, it lead me from the
> libertas driver to mmc, esp. in drivers/mmc/core.c the
> mmc_wait_for_req(...) function. It was done without mmc debugging
> messages, with libertas debugging symbols activated but not printed
> out.

Just for context, what SDIO controller are you using on this platform?

Dan

> From there on, I switched to the wireless git[3] in order to be able
> to provide more convinient patches if needed. I immediately patched i=
t
> against the attached proposal from last thread[4], adapting it due to
> compile issues (see below). I also gave a quick try at Philip's
> proposal[5], which didn't seem to work, unfortunately.
>=20
> about the patch: I didn't adapt it as proposed latter on in the threa=
d
> by setting 0 values, but by reinserting the "old"
> cmd_ds_802_11_get_log log structure. Wrong thing?
>=20
> The good news using this kernel was that I wasn't always stuck in a
> hang: listing the APs works, connecting to an AP using WPA & french
> bands failed, yet without hanging (here, I had MMC & libertas
> debugging messages).
>=20
> The bad news is I can reproduce the hang using these sources quite
> easily if I do, say: an association request, followed by an iwconfig
> to check if the association was done *before* all the attempts were
> done. The attempts I did using iwconfig once the previous one
> timed-out were successfull.
>=20
> This leads me to think there are in fact two issues:
>  - an association issue (at least in France). Maybe not much of a
>    problem? I might even be the one doing the wrong thing, not the
>    kernel :)
>  - an issue when accessing the card (race condition?), which could be
>    more subtle to handle.
>=20
> Using the fresh 2.6.31-rc6 kernel.org release, with MMC & libertas
> debugging messages on, I still can do an association request without
> getting neither a hang, nor an association. So maybe one of the race
> issues that are patched in it do solve part of this problem. Yet,
> running several AP association requests does hang.
>=20
> I'd be glad to do more testing and provide usefull information. Any
> idea(s) on which track(s) I should now follow and how I can help you
> solve this issue?
>=20
> Thanks,
>=20
> --=20
> Beno=C3=AEt
>=20
> [1] http://lists.infradead.org/pipermail/libertas-dev/2009-June/00248=
7.html
> [2] http://lists.infradead.org/pipermail/libertas-dev/2009-June/00251=
0.html
> [3] git://git.kernel.org/pub/scm/linux/kernel/git/linville/wireless-t=
esting.git
> [4] http://lists.infradead.org/pipermail/libertas-dev/2009-June/00249=
6.html
> [5] http://lists.infradead.org/pipermail/libertas-dev/2009-June/00249=
4.html
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

