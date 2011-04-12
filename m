From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: Low performance Intel 10GE NIC (3.2.10) on 2.6.38 Kernel
Date: Tue, 12 Apr 2011 06:56:41 +0200
Message-ID: <1302584201.3603.20.camel@edumazet-laptop>
References: <D12839161ADD3A4B8DA63D1A134D084026E48B9BEB@ESGSCCMS0001.eapac.ericsson.se>
	 <D12839161ADD3A4B8DA63D1A134D084026E48B9F23@ESGSCCMS0001.eapac.ericsson.se>
	 <1302167168.3357.12.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA027@ESGSCCMS0001.eapac.ericsson.se>
	 <1302176811.3357.15.camel@edumazet-laptop>  <4D9DDF43.9080302@intel.com>
	 <1302192218.3357.47.camel@edumazet-laptop> <4D9DE465.1080008@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA58D@ESGSCCMS0001.eapac.ericsson.se>
	 <1302253651.4409.2.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA66B@ESGSCCMS0001.eapac.ericsson.se>
	 <1302267400.4409.22.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA682@ESGSCCMS0001.eapac.ericsson.se>
	 <1302275223.4409.36.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA6AE@ESGSCCMS0001.eapac.ericsson.se>
	 <1302330998.2656.113.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E48BA730@ESGSCCMS0001.eapac.ericsson.se>
	 <4DA3151B.4030507@intel.com>
	 <D12839161ADD3A4B8DA63D1A134D084026E4909714@ESGSCCMS0001.eapac.ericsson.se>
	 <1302536577.4605.1.camel@edumazet-laptop>
	 <D12839161ADD3A4B8DA63D1A134D084026E490995D@ESGSCCMS0001.eapac.ericsson.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	netdev <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: Wei Gu <wei.gu@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:63677 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750783Ab1DLE4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Apr 2011 00:56:47 -0400
Received: by wya21 with SMTP id 21so5367546wya.19
        for <netdev@vger.kernel.org>; Mon, 11 Apr 2011 21:56:46 -0700 (PDT)
In-Reply-To: <D12839161ADD3A4B8DA63D1A134D084026E490995D@ESGSCCMS0001.eapac.ericsson.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 avril 2011 =C3=A0 12:40 +0800, Wei Gu a =C3=A9crit :
> Hi,
> I found the problem was introduced by this revert patch "2010-08-13
> Peter Zijlstra  sched: Revert nohz_ratelimit() for now"
>=20
> I tried the remove this patch from 2.6.35.2 and then build the
> application again, then the ixgbe driver looks works fine.
> I don't know why this time revert the  nohz_ratelimit() will cause th=
e
> problem on ixgbe driver, since this  nohz_ratelimit was first
> introduced "2010-03-11". And before that time with 2.6.32 kernel it
> also doesn't have this problem with ixgbe driver.
>=20
>=20
> Some log from git:
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> 2.6.35.2
> 2010-08-13      Peter Zijlstra  sched: Revert nohz_ratelimit() for no=
w
> 2.6.35.1
> 2010-08-01      Linus Torvalds  Linux 2.6.35 v2.6.35
> 2010-06-17      Peter Zijlstra  nohz: Fix nohz ratelimit
> 2.6.35-rc3
> 2010-03-11      Mike Galbraith  sched: Rate-limit nohz
>=20
> Thanks
> WeiGu
>=20

Hmm...

Could you try to add "processor.max_cstate=3D1" to boot parameters ?



