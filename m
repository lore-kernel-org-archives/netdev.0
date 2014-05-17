From: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH] drivers: net: ethernet: mellanox: mlx4: let mlx4 depend on
 SMP
Date: Sat, 17 May 2014 13:26:16 +0800
Message-ID: <5376F2F8.3010603@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Guan Xuetao <gxt-TG0Ac1+ktVePQbnJrJN+5g@public.gmane.org>, matanb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, eyalpe-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
	amirv-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org, sbohrer-EgGFQ3RFNTIP7C3xziwOQw@public.gmane.org,
	linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	"linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

'struct irq_affinity_notify' and the related functions are only defined
when SMP enabled, so at present, mlx4 has to only run under SMP.

The related error (allmodconfig under unicore32):

    CC [M]  drivers/net/ethernet/mellanox/mlx4/eq.o
  drivers/net/ethernet/mellanox/mlx4/eq.c:58: error: field =91notify=92=
 has incomplete type
  drivers/net/ethernet/mellanox/mlx4/eq.c: In function =91mlx4_irq_noti=
fier_notify=92:
  drivers/net/ethernet/mellanox/mlx4/eq.c:1094: error: type defaults to=
 =91int=92 in declaration of =91__mptr=92
  drivers/net/ethernet/mellanox/mlx4/eq.c:1094: warning: initialization=
 from incompatible pointer type
  drivers/net/ethernet/mellanox/mlx4/eq.c:1104: error: dereferencing po=
inter to incomplete type
  drivers/net/ethernet/mellanox/mlx4/eq.c: In function =91mlx4_release_=
irq_notifier=92:
  drivers/net/ethernet/mellanox/mlx4/eq.c:1111: error: type defaults to=
 =91int=92 in declaration of =91__mptr=92
  drivers/net/ethernet/mellanox/mlx4/eq.c:1111: warning: initialization=
 from incompatible pointer type
  drivers/net/ethernet/mellanox/mlx4/eq.c: In function =91mlx4_assign_i=
rq_notifier=92:
  drivers/net/ethernet/mellanox/mlx4/eq.c:1133: error: implicit declara=
tion of function =91irq_set_affinity_notifier=92
  make[5]: *** [drivers/net/ethernet/mellanox/mlx4/eq.o] Error 1
  make[4]: *** [drivers/net/ethernet/mellanox/mlx4] Error 2
  make[3]: *** [drivers/net/ethernet/mellanox] Error 2
  make[2]: *** [drivers/net/ethernet] Error 2
  make[1]: *** [drivers/net] Error 2
  make: *** [drivers] Error 2

Signed-off-by: Chen Gang <gang.chen.5i5j-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/infiniband/hw/mlx4/Kconfig         | 2 +-
 drivers/net/ethernet/mellanox/mlx4/Kconfig | 2 +-
 2 files changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/infiniband/hw/mlx4/Kconfig b/drivers/infiniband/hw=
/mlx4/Kconfig
index fc01dea..e31e400 100644
--- a/drivers/infiniband/hw/mlx4/Kconfig
+++ b/drivers/infiniband/hw/mlx4/Kconfig
@@ -1,6 +1,6 @@
 config MLX4_INFINIBAND
 	tristate "Mellanox ConnectX HCA support"
-	depends on NETDEVICES && ETHERNET && PCI && INET
+	depends on NETDEVICES && ETHERNET && PCI && INET && SMP
 	select NET_VENDOR_MELLANOX
 	select MLX4_CORE
 	---help---
diff --git a/drivers/net/ethernet/mellanox/mlx4/Kconfig b/drivers/net/e=
thernet/mellanox/mlx4/Kconfig
index 1486ce9..a1f2380 100644
--- a/drivers/net/ethernet/mellanox/mlx4/Kconfig
+++ b/drivers/net/ethernet/mellanox/mlx4/Kconfig
@@ -4,7 +4,7 @@
=20
 config MLX4_EN
 	tristate "Mellanox Technologies 1/10/40Gbit Ethernet support"
-	depends on PCI
+	depends on PCI && SMP
 	select MLX4_CORE
 	select PTP_1588_CLOCK
 	---help---
--=20
1.9.2.459.g68773ac
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
