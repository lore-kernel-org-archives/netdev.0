From: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
Subject: [PATCH 1/7] ptp_pch: Add dependency on HAS_IOMEM
Date: Tue, 14 Jan 2014 16:45:39 +0100
Message-ID: <1389714345-20165-1-git-send-email-richard@nod.at>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sebastian.hesselbarth-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, florian-p3rKhJxN3npAfugRpC6u6w@public.gmane.org,
	thomas.petazzoni-wi1+55ScJUtKEb57/3fJTNBPR1lH4CV8@public.gmane.org, lars-Qo5EllUWu/uELgA04lAiVw@public.gmane.org,
	marex-ynQEQJNshbs@public.gmane.org, acourbot-DDmLM1+adcrQT0dZR+AlfA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	driverdev-devel-tBiZLqfeLfOHmIFyCCdPziST3g8Odh+X@public.gmane.org, devel-gWbeCf7V1WCQmaza687I9mD2FQJk+8+b@public.gmane.org,
	linux-iio-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
To: kishon-l0cyMroinI0@public.gmane.org, anton-9xeibp6oKSgdnm+yROfE0A@public.gmane.org, dwmw2-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org,
	richardcochran-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, lidza.louina-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	gregkh-hQyY1W1yCW8ekmWlsbkhG0B+6BGkLq7r@public.gmane.org, jic23-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Sender: linux-iio-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On archs like S390 or um this driver cannot build nor work.
Make it depend on HAS_IOMEM to bypass build failures.

drivers/ptp/ptp_pch.c: In function =E2=80=98pch_remove=E2=80=99:
drivers/ptp/ptp_pch.c:571:3: error: implicit declaration of function =E2=
=80=98iounmap=E2=80=99 [-Werror=3Dimplicit-function-declaration]
drivers/ptp/ptp_pch.c: In function =E2=80=98pch_probe=E2=80=99:
drivers/ptp/ptp_pch.c:621:2: error: implicit declaration of function =E2=
=80=98ioremap=E2=80=99 [-Werror=3Dimplicit-function-declaration]

Signed-off-by: Richard Weinberger <richard-/L3Ra7n9ekc@public.gmane.org>
---
 drivers/ptp/Kconfig | 1 +
 1 file changed, 1 insertion(+)

diff --git a/drivers/ptp/Kconfig b/drivers/ptp/Kconfig
index 5be73ba..5a7910e 100644
--- a/drivers/ptp/Kconfig
+++ b/drivers/ptp/Kconfig
@@ -73,6 +73,7 @@ config DP83640_PHY
 config PTP_1588_CLOCK_PCH
 	tristate "Intel PCH EG20T as PTP clock"
 	depends on X86 || COMPILE_TEST
+	depends on HAS_IOMEM
 	select PTP_1588_CLOCK
 	help
 	  This driver adds support for using the PCH EG20T as a PTP
--=20
1.8.1.4
