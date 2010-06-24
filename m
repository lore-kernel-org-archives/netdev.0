From: Pedro Garcia Pelaez <pedro@dondevamos.com>
Subject: Re: [PATCH] =?UTF-8?Q?vlan=5Fdev=3A=20VLAN=20=30=20should=20be=20treated?=
 =?UTF-8?Q?=20as=20=22no=20vlan=20tag=22=20=28=38=30=32=2E=31p=20packet=29?=
Date: Thu, 24 Jun 2010 20:28:02 +0200
Message-ID: <0cf29e9ad0852452e7aeecbd90d44bed@dondevamos.com>
References: <c25bca517739ada31d698235c3a4d045@dondevamos.com> <1276466190.14011.223.camel@localhost> <5c6d1ac43fd8ad25661ebfba57c02174@dondevamos.com> <1276534945.2074.11.camel@achroite.uk.solarflarecom.com> <4C1662C3.3070708@trash.net> <1276542772.2444.13.camel@edumazet-laptop> <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Pedro Garcia <pedro.netdev@dondevamos.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 13.Red-213-97-209.staticIP.rima-tde.net ([213.97.209.13]:59212
	"EHLO smtp1.dondevamos.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751083Ab0FXTMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Jun 2010 15:12:55 -0400
In-Reply-To: <311b59aee7d648c6124a84b5ca06ac60@dondevamos.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 16 Jun 2010 10:49:27 +0200, Pedro Garcia
<pedro.netdev@dondevamos.com> wrote:
> On Mon, 14 Jun 2010 21:12:52 +0200, Eric Dumazet
<eric.dumazet@gmail.com>
> wrote:
>> Le lundi 14 juin 2010 =C3=A0 19:11 +0200, Patrick McHardy a =C3=A9cr=
it :
>>> Ben Hutchings wrote:
>>> > On Mon, 2010-06-14 at 18:49 +0200, Pedro Garcia wrote:
>>> >  =20
>>> >> On Sun, 13 Jun 2010 22:56:30 +0100, Ben Hutchings
>>> >> <bhutchings@solarflare.com> wrote:
>>> >>    =20
>>> >>> I have no particular opinion on this change, but you need to re=
ad
>>> >>> and
>>> >>> follow Documentation/SubmittingPatches.
>>> >>>
>>> >>> Ben.
>>> >>>      =20
>>> >> Sorry, first kernel patch, and I did not know about it. I resubm=
it
>>> >> with
>>> >> the correct style / format:
>>> >>    =20
>>> > [...]
>>> >
>>> > Sorry, no you haven't.
>>> >
>>> > - Networking changes go through David Miller's net-next-2.6 tree =
so
>>> > you
>>> > need to use that as the baseline, not 2.6.26
>>> > - Patches should be applicable with -p1, not -p0 (so if you use
diff,
>>> > you should run it from one directory level up)
>>> > - The patch was word-wrapped
>>>=20
>>> Additionally:
>>>=20
>>> - please use the proper comment style, meaning each line begins
>>>   with a '*'
>>>=20
>>> - the pr_debug statements may be useful for debugging, but are
>>>   a bit excessive for the final version
>>>=20
>>> - + /* 2010-06-13: Pedro Garcia
>>>=20
>>>    We have changelogs for this, simply explaining what the code
>>>    does is enough.
>>>=20
>>> - Please CC the maintainer (which is me)
>>> --
>>=20
>> Pedro, we have two kind of vlan setups :
>>=20
>> accelerated and non accelerated ones.
>>=20
>> Your patch address non accelated ones only, since you only touch
>> vlan_skb_recv()
>>=20
>> Accelerated vlan can follow these paths :
>>=20
>> 1) NAPI devices
>>=20
>> vlan_gro_receive() -> vlan_gro_common()
>>=20
>> 2) non NAPI devices
>>=20
>> __vlan_hwaccel_rx()=20
>>=20
>> So you might also patch __vlan_hwaccel_rx() and vlan_gro_common()
>>=20
>> Please merge following bits to your patch submission :
>>=20
>> http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868
>>=20
>>=20
>> Good luck for your first patch !
>=20
> Here it is again. I added the modifications in
> http://kerneltrap.org/mailarchive/linux-netdev/2010/5/23/6277868 for =
HW
> accelerated incoming packets (it did not apply cleanly on the last
version
> of
> the kernel, so I applied manually). Now, if the VLAN 0 is not explici=
tly
> created by the user, VLAN 0 packets will be treated as no VLAN (802.1=
p
> packets), instead of dropping them.
>=20
> The patch is now for two files: vlan_core (accel) and vlan_dev (non
accel)
>=20
> I can not test on HW accelerated devices, so if someone can check it =
I
> will appreciate (even though in the thread above it looked like yes).
=46or
> non accel I tessted in 2.6.26. Now the patch is for
> net-next-2.6, and it compiles OK, but I a have to setup a test
environment
> to check it is still OK (should, but better to test).
>=20

I tested the pacth under net-next-2.6, and it OOPSed the kernel (worked
under 2.6.26 but not under 2.6.35). I have found why and solved it, but
now, to my surprise, it only works when I leave the interface in
promiscuous mode.

After a lot of debugging, looks like the skb does not even arrive to
__netif_receive_skb, unless in promiscuous mode. Under what circunstanc=
es
could this happen?

Pedro=20
