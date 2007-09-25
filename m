From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: 2.6.23-rc8-mm1 - drivers/net/ibm_newemac/mal - broken
Date: Tue, 25 Sep 2007 09:16:13 -0700
Message-ID: <20070925091613.44042909.akpm@linux-foundation.org>
References: <20070925014625.3cd5f896.akpm@linux-foundation.org>
	<46F904E6.40601@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, eugene.surovegin@zultys.com,
	netdev@vger.kernel.org
To: Kamalesh Babulal <kamalesh@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:56956 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755286AbXIYQQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Sep 2007 12:16:42 -0400
In-Reply-To: <46F904E6.40601@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 25 Sep 2007 18:23:58 +0530 Kamalesh Babulal <kamalesh@linux.vne=
t.ibm.com> wrote:

> Hi Andrew,
>=20
> The drivers/net/ibm_newemac/mal seems to be broken, which stop with
> build error

(please cc netdev@vger.kernel.org on networking things)

> CC      drivers/net/ibm_newemac/mal.o
> drivers/net/ibm_newemac/mal.c: In function =E2=80=98mal_schedule_poll=
=E2=80=99:
> drivers/net/ibm_newemac/mal.c:238: error: too few arguments to functi=
on =E2=80=98netif_rx_schedule_prep=E2=80=99
> drivers/net/ibm_newemac/mal.c:238: error: too few arguments to functi=
on =E2=80=98netif_rx_schedule_prep=E2=80=99
> drivers/net/ibm_newemac/mal.c:238: error: too few arguments to functi=
on =E2=80=98netif_rx_schedule_prep=E2=80=99
> drivers/net/ibm_newemac/mal.c:241: error: too few arguments to functi=
on =E2=80=98__netif_rx_schedule=E2=80=99
> drivers/net/ibm_newemac/mal.c: In function =E2=80=98mal_poll_disable=E2=
=80=99:
> drivers/net/ibm_newemac/mal.c:321: error: =E2=80=98__LINK_STATE_RX_SC=
HED=E2=80=99 undeclared (first use in this function)
> drivers/net/ibm_newemac/mal.c:321: error: (Each undeclared identifier=
 is reported only once
> drivers/net/ibm_newemac/mal.c:321: error: for each function it appear=
s in.)
> drivers/net/ibm_newemac/mal.c: In function =E2=80=98mal_poll=E2=80=99=
:
> drivers/net/ibm_newemac/mal.c:337: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98quota=E2=80=99
> drivers/net/ibm_newemac/mal.c:337: warning: type defaults to =E2=80=98=
int=E2=80=99 in declaration of =E2=80=98_x=E2=80=99
> drivers/net/ibm_newemac/mal.c:337: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98quota=E2=80=99
> drivers/net/ibm_newemac/mal.c:375: error: too few arguments to functi=
on =E2=80=98__netif_rx_complete=E2=80=99
> drivers/net/ibm_newemac/mal.c:390: warning: passing argument 2 of =E2=
=80=98netif_rx_reschedule=E2=80=99 makes pointer from integer without a=
 cast
> drivers/net/ibm_newemac/mal.c:404: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98quota=E2=80=99
> drivers/net/ibm_newemac/mal.c: In function =E2=80=98mal_probe=E2=80=99=
:
> drivers/net/ibm_newemac/mal.c:542: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98weight=E2=80=99
> drivers/net/ibm_newemac/mal.c:543: error: =E2=80=98struct net_device=E2=
=80=99 has no member named =E2=80=98poll=E2=80=99
> drivers/net/ibm_newemac/mal.c: In function =E2=80=98mal_remove=E2=80=99=
:
> drivers/net/ibm_newemac/mal.c:660: error: implicit declaration of fun=
ction =E2=80=98netif_poll_disable=E2=80=99
> make[3]: *** [drivers/net/ibm_newemac/mal.o] Error 1
> make[2]: *** [drivers/net/ibm_newemac] Error 2
> make[1]: *** [drivers/net] Error 2
> make: *** [drivers] Error 2

Yes, there's been a lot of breakage in netdev land:

git-net-fix-macec.patch
git-net-sky2-fixups.patch
git-net-fix-wireless-kconfig.patch
git-net-fix-spidernet-build.patch
git-net-sctp-build-fix.patch
spider_net_ethtool-keep-up-with-recent-netdev-stats-changes.patch
pasemi_mac-build-fix-after-recent-netdev-stats.patch
git-net-fix-pasemi_mac.patch
make-mv643xx_ethc-build-again.patch

but we're getting there.  It looks like ibmn_newemac is more busted tha=
n
most...
