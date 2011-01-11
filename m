From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Bug#609538: r8169: long delay during resume
Date: Tue, 11 Jan 2011 21:28:17 +0100
Message-ID: <20110111202817.GA2538@electric-eye.fr.zoreil.com>
References: <20110110131439.GA663@rocket.almost.secure.la> <1294724952.3235.2.camel@localhost> <4D2C06CF.4090507@vilo.eu.org> <20110111132524.GA2479@electric-eye.fr.zoreil.com> <4D2C9FA8.7010401@vilo.eu.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Ben Hutchings <ben@decadent.org.uk>, 609538@bugs.debian.org,
	Hayes Wang <hayeswang@realtek.com>,
	netdev <netdev@vger.kernel.org>
To: Jarek =?utf-8?B?S2FtacWEc2tp?= <jarek@vilo.eu.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:60268 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753368Ab1AKU24 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jan 2011 15:28:56 -0500
Content-Disposition: inline
In-Reply-To: <4D2C9FA8.7010401@vilo.eu.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Kami=C5=84ski <jarek@vilo.eu.org> :
[failure]

/me slaps head

Please check that it works if you add the patch below and I'll
merge both for a proper submission.

r8169: I am a clown.

Modifying rtl8169_reset_task() to tolerate firmware changes between
close() and open() but this is not high-priority.

Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
index 7e2f01c..57fa6bd 100644
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -3119,6 +3119,8 @@ static void __devexit rtl8169_remove_one(struct p=
ci_dev *pdev)
=20
 	cancel_delayed_work_sync(&tp->task);
=20
+	rtl_release_firmware(tp);
+
 	unregister_netdev(dev);
=20
 	if (pci_dev_run_wake(pdev))
@@ -4679,8 +4681,6 @@ static int rtl8169_close(struct net_device *dev)
 	tp->TxDescArray =3D NULL;
 	tp->RxDescArray =3D NULL;
=20
-	rtl_release_firmware(tp);
-
 	pm_runtime_put_sync(&pdev->dev);
=20
 	return 0;

> "r8169: delay phy init until device opens." alone also doesn't do the=
 trick.

It was the expected behavior.

--=20
Ueimor
