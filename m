From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: RE: [BUG net-next] bnx2x: all traffic comes to RX queue 0
Date: Tue, 12 Oct 2010 20:11:43 +0200
Message-ID: <1286907103.2703.6.camel@edumazet-laptop>
References: <1286838210.30423.128.camel@edumazet-laptop>
	 <1286899657.2732.93.camel@edumazet-laptop>
	 <2DFD360E328B3941911E6D28B085D990129FC2028B@SJEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, Michael Chan <mchan@broadcom.com>,
	Eilon Greenstein <eilong@broadcom.com>,
	David Miller <davem@davemloft.net>,
	Vladislav Zolotarov <vladz@broadcom.com>,
	Yaniv Rosner <yaniv.rosner@broadcom.com>
To: Dmitry Kravkov <dmitry@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:37010 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753612Ab0JLSMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Oct 2010 14:12:05 -0400
Received: by wwj40 with SMTP id 40so5392964wwj.1
        for <netdev@vger.kernel.org>; Tue, 12 Oct 2010 11:12:03 -0700 (PDT)
In-Reply-To: <2DFD360E328B3941911E6D28B085D990129FC2028B@SJEXCHCCR01.corp.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 12 octobre 2010 =C3=A0 09:20 -0700, Dmitry Kravkov a =C3=A9cri=
t :
> Eric,
>=20
> I will take a look
>=20

Thanks ! Here is the bisection result

# git bisect bad
523224a3b3cd407ce4e6731a087194e13a90db18 is the first bad commit
commit 523224a3b3cd407ce4e6731a087194e13a90db18
Author: Dmitry Kravkov <dmitry@broadcom.com>
Date:   Wed Oct 6 03:23:26 2010 +0000

    bnx2x, cnic, bnx2i: use new FW/HSI
   =20
    This is the new FW HSI blob and the relevant definitions without lo=
gic changes.
    It also included code adaptation for new HSI. New features are not =
enabled.
   =20
    New FW/HSI includes:
    - Support for 57712 HW
    - Future support for VF (not used)
    - Improvements in FW interrupts scheme
    - FW FCoE hooks (stubs for future usage)
   =20
    Signed-off-by: Dmitry Kravkov <dmitry@broadcom.com>
    Signed-off-by: Michael Chan <mchan@broadcom.com>
    Signed-off-by: Eilon Greenstein <eilong@broadcom.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

:040000 040000 8931a748ae89487466d99e6121a3965131e3a201 fed2be49565ca29=
1203a865554a0e071a2a9c3fb M	drivers
:040000 040000 2ff6a5c290ca7e9dc339b7213f49c341f4fc5822 82c0a7117b58f53=
8a8b49891c5524e3537c5ae66 M	firmware


# git bisect log
git bisect start '--' 'drivers/net/bnx2x'
# bad: [b9e9b15966e35f3b4a8d3820cac460505552f72c] Merge branch 'master'=
 of git://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next-2.6
git bisect bad b9e9b15966e35f3b4a8d3820cac460505552f72c
# good: [9fe6206f400646a2322096b56c59891d530e8d51] Linux 2.6.35
git bisect good 9fe6206f400646a2322096b56c59891d530e8d51
# good: [b7737c9be9d3e894d1a4375c52f5f47789475f26] bnx2x: Split PHY fun=
ctions
git bisect good b7737c9be9d3e894d1a4375c52f5f47789475f26
# good: [8681dc3abd54e845a2effab441921b4c4457c241] bnx2x: Moved enablin=
g of MSI to the bnx2x_set_num_queues()
git bisect good 8681dc3abd54e845a2effab441921b4c4457c241
# bad: [c518cd1c7aca2e2a65edcf4fa5ce4160d59878c2] bnx2x: remove unused =
fields in main driver structure
git bisect bad c518cd1c7aca2e2a65edcf4fa5ce4160d59878c2
# bad: [fb3bff178e722fe88b5ab02319c9636da0980e25] bnx2x: rename MF rela=
ted fields
git bisect bad fb3bff178e722fe88b5ab02319c9636da0980e25
# good: [560131f313ea9b9439742138289b6f68d61531ec] bnx2x: create folder=
 for bnx2x firmware files
git bisect good 560131f313ea9b9439742138289b6f68d61531ec
# bad: [523224a3b3cd407ce4e6731a087194e13a90db18] bnx2x, cnic, bnx2i: u=
se new FW/HSI
git bisect bad 523224a3b3cd407ce4e6731a087194e13a90db18


