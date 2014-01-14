From: Richard Weinberger <richard@nod.at>
Subject: [PATCH 2/7] staging,dgap: Add dependency on HAS_IOMEM
Date: Tue, 14 Jan 2014 16:45:40 +0100
Message-ID: <1389714345-20165-2-git-send-email-richard@nod.at>
References: <1389714345-20165-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.hesselbarth@gmail.com, florian@openwrt.org,
	thomas.petazzoni@free-electrons.com, lars@metafoo.de,
	marex@denx.de, acourbot@nvidia.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	driverdev-devel@linuxdriverproject.org, devel@driverdev.osuosl.org,
	linux-iio@vger.kernel.org, Richard Weinberger <richard@nod.at>
To: kishon@ti.com, anton@enomsg.org, dwmw2@infradead.org,
	richardcochran@gmail.com, lidza.louina@gmail.com,
	gregkh@linuxfoundation.org, jic23@kernel.org, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1389714345-20165-1-git-send-email-richard@nod.at>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On archs like S390 or um this driver cannot build nor work.
Make it depend on HAS_IOMEM to bypass build failures.

drivers/staging/dgap/dgap_driver.c: In function =E2=80=98dgap_cleanup_b=
oard=E2=80=99:
drivers/staging/dgap/dgap_driver.c:457:3: error: implicit declaration o=
f function =E2=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]
drivers/staging/dgap/dgap_driver.c: In function =E2=80=98dgap_do_remap=E2=
=80=99:
drivers/staging/dgap/dgap_driver.c:694:2: error: implicit declaration o=
f function =E2=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-decla=
ration]

Signed-off-by: Richard Weinberger <richard@nod.at>
---
 drivers/staging/dgap/Kconfig | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/drivers/staging/dgap/Kconfig b/drivers/staging/dgap/Kconfi=
g
index 31f1d75..3bbe9e1 100644
--- a/drivers/staging/dgap/Kconfig
+++ b/drivers/staging/dgap/Kconfig
@@ -1,6 +1,6 @@
 config DGAP
        tristate "Digi EPCA PCI products"
        default n
-       depends on TTY
+       depends on TTY && HAS_IOMEM
        ---help---
        Driver for the Digi International EPCA PCI based product line
--=20
1.8.1.4
