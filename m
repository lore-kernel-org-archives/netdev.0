From: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
Subject: [PATCH] mISDN: Ignore return value of driver_for_each_device in function hfcpci_softirq.
Date: Wed, 25 Apr 2012 00:13:50 +0100
Message-ID: <1335309230-23428-1-git-send-email-krzysztof.wilczynski@linux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Simon Horman <horms@verge.net.au>,
	Jiri Kosina <trivial@kernel.org>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Karsten Keil <isdn@linux-pingi.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46unction hfcpci_softirq uses driver_for_each_device to call _hfcpci_s=
oftirq for
each device. Given that _hfcpci_softirq always returns 0, we collect th=
is return
value and simply do nothing with it.  This is purely to address the fol=
lowing
warning during compilation time:

  drivers/isdn/hardware/mISDN/hfcpci.c: In function =E2=80=98hfcpci_sof=
tirq=E2=80=99:
  drivers/isdn/hardware/mISDN/hfcpci.c:2319: warning: ignoring return v=
alue of
    =E2=80=98driver_for_each_device=E2=80=99, declared with attribute w=
arn_unused_result

Similar approach was used in function cx18_alsa_exit from "cx18-alsa-ma=
in.c".

Signed-off-by: Krzysztof Wilczynski <krzysztof.wilczynski@linux.com>
---
 drivers/isdn/hardware/mISDN/hfcpci.c |    7 +++++--
 1 files changed, 5 insertions(+), 2 deletions(-)

diff --git a/drivers/isdn/hardware/mISDN/hfcpci.c b/drivers/isdn/hardwa=
re/mISDN/hfcpci.c
index e2c83a2..f0d0180 100644
--- a/drivers/isdn/hardware/mISDN/hfcpci.c
+++ b/drivers/isdn/hardware/mISDN/hfcpci.c
@@ -2316,8 +2316,11 @@ _hfcpci_softirq(struct device *dev, void *arg)
 static void
 hfcpci_softirq(void *arg)
 {
-	(void) driver_for_each_device(&hfc_driver.driver, NULL, arg,
-				      _hfcpci_softirq);
+	int ret;
+
+	/* Collect return value, but do not use it; suppress GCC warning ... =
*/
+	ret =3D driver_for_each_device(&hfc_driver.driver, NULL, arg,
+				     _hfcpci_softirq);
=20
 	/* if next event would be in the past ... */
 	if ((s32)(hfc_jiffies + tics - jiffies) <=3D 0)
--=20
1.7.2.5
