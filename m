From: Ron Mercer <ron.mercer@qlogic.com>
Subject: [PATCH 2/2] qlge: Protect qlge_resume() with CONFIG_PM
Date: Fri, 26 Sep 2008 15:25:26 -0700
Message-ID: <1222467926-19164-2-git-send-email-ron.mercer@qlogic.com>
References: <20080926222434.GA19152@susedev.qlogic.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, linux-driver@qlogic.com,
	ron.mercer@qlogic.com, David Miller <davem@davemloft.net>
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from avexch1.qlogic.com ([198.70.193.115]:38405 "EHLO
	avexch1.qlogic.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752227AbYIZWZl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 18:25:41 -0400
In-Reply-To: <20080926222434.GA19152@susedev.qlogic.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: David Miller <davem@davemloft.net>

qlge: Protect qlge_resume() with CONFIG_PM

=46ixes the following build warning:

drivers/net/qlge/qlge_main.c:3897: warning: =E2=80=98qlge_resume=E2=80=99=
 defined but not used

Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Ron Mercer <ron.mercer@qlogic.com>
---
 drivers/net/qlge/qlge_main.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/drivers/net/qlge/qlge_main.c b/drivers/net/qlge/qlge_main.=
c
index ad878e2..3af822b 100644
--- a/drivers/net/qlge/qlge_main.c
+++ b/drivers/net/qlge/qlge_main.c
@@ -3893,6 +3893,7 @@ static int qlge_suspend(struct pci_dev *pdev, pm_=
message_t state)
 	return 0;
 }
=20
+#ifdef CONFIG_PM
 static int qlge_resume(struct pci_dev *pdev)
 {
 	struct net_device *ndev =3D pci_get_drvdata(pdev);
@@ -3921,6 +3922,7 @@ static int qlge_resume(struct pci_dev *pdev)
=20
 	return 0;
 }
+#endif /* CONFIG_PM */
=20
 static void qlge_shutdown(struct pci_dev *pdev)
 {
--=20
1.6.0

