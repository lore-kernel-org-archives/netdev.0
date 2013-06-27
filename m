From: Chen Gang <gang.chen@asianux.com>
Subject: [PATCH] drivers/ptp/Kconfig: add "depends on HAS_IOMEM" for 'PTP_1588_CLOCK_PCH'
Date: Thu, 27 Jun 2013 08:52:07 +0800
Message-ID: <51CB8CB7.6010006@asianux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Richard Weinberger <richard@nod.at>,
	Geert Uytterhoeven <geert@linux-m68k.org>
To: richardcochran@gmail.com, netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from intranet.asianux.com ([58.214.24.6]:61119 "EHLO
	intranet.asianux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751557Ab3F0AxA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Jun 2013 20:53:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The related driver need depend on HAS_IOMEM, or may be built under UML
architecture.

The related error (with allmodconfig, without pcap):

    CC [M]  drivers/ptp/ptp_pch.o
  drivers/ptp/ptp_pch.c: In function =91pch_remove=92:
  drivers/ptp/ptp_pch.c:571:3: error: implicit declaration of function =
=91iounmap=92 [-Werror=3Dimplicit-function-declaration]
  drivers/ptp/ptp_pch.c: In function =91pch_probe=92:
  drivers/ptp/ptp_pch.c:621:2: error: implicit declaration of function =
=91ioremap=92 [-Werror=3Dimplicit-function-declaration]
  drivers/ptp/ptp_pch.c:621:13: warning: assignment makes pointer from =
integer without a cast [enabled by default]
  cc1: some warnings being treated as errors

Signed-off-by: Chen Gang <gang.chen@asianux.com>
---
 drivers/ptp/Kconfig |    1 +
 1 files changed, 1 insertions(+), 0 deletions(-)

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
1.7.7.6
