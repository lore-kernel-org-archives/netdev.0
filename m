From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: [PATCH 0/3] net: mv643xx_eth: various small fixes for v3.12
Date: Fri, 4 Oct 2013 13:53:55 -0300
Message-ID: <20131004165354.GA9065@localhost>
References: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	David Miller <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1380711442-24735-1-git-send-email-sebastian.hesselbarth@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Oct 02, 2013 at 12:57:19PM +0200, Sebastian Hesselbarth wrote:
> This patch set comprises some one-liners to fix issues with repeated
> loading and unloading of a modular mv643xx_eth driver.
>=20
> First two patches take care of the periodic port statistic timer, tha=
t
> updates statistics by reading port registers using add_timer/mod_time=
r.
>=20
> Patch 1 moves timer re-schedule from mib_counters_update to the timer
> callback. As mib_counters_update is also called from non-timer contex=
t,
> this ensures the timer is reactivated from timer context only.
>=20
> Patch 2 moves initial timer schedule from _probe() time to right befo=
re
> the port is actually started as the corresponding del_timer_sync is a=
t
> _stop() time. This fixes a regression, where unloading the driver fro=
m a
> non-started eth device can cause the timer to access deallocated mem.
>=20
> Patch 3 adds an assignment of the ports device_node to the correspond=
ing
> self-created platform_device. This is required to allow fixups based =
on
> the device_node's compatible string later. Actually, it is also a pot=
ential
> regression because we already check compatible string for Kirkwood, b=
ut
> does not (yet) rely on the fixup.
>=20
> All patches are based on v3.12-rc3 and have been tested on Kirkwood-b=
ased
> Seagate Dockstar.
>=20
> Patches 1 and 2 can also possibly queued up for -stable.
>=20
> Sebastian Hesselbarth (3):
>   net: mv643xx_eth: update statistics timer from timer context only
>   net: mv643xx_eth: fix orphaned statistics timer crash
>   net: mv643xx_eth: fix missing device_node for port devices
>=20
>  drivers/net/ethernet/marvell/mv643xx_eth.c |    7 +++----
>  1 file changed, 3 insertions(+), 4 deletions(-)
>=20
> ---
> Cc: David Miller <davem@davemloft.net>
> Cc: Lennert Buytenhek <buytenh@wantstofly.org>
> Cc: Jason Cooper <jason@lakedaemon.net>
> Cc: netdev@vger.kernel.org
> Cc: linux-arm-kernel@lists.infradead.org
> Cc: linux-kernel@vger.kernel.org

Sorry for missing this series, somehow my filters failed to catch it.

Anyway, I would expect these patches to have my Reported-by, but I'm
glad to see you've solved all the issues.

I see David has already applied them all, but I'll re-run my tests to
check there aren't any more issues if I can find some time next week.

Thanks for taking care of it!
--=20
Ezequiel Garc=C3=ADa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
