From: Toru UCHIYAMA <uchiyama.toru@jp.fujitsu.com>
Subject: [PATCH]gianfar: gfar_remove needs to call unregister_netdev()
Date: Thu, 20 Aug 2009 22:54:35 +0900
Message-ID: <4A8D559B.3030108@jp.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fgwmail6.fujitsu.co.jp ([192.51.44.36]:35916 "EHLO
	fgwmail6.fujitsu.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754168AbZHTNzU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Aug 2009 09:55:20 -0400
Received: from m5.gw.fujitsu.co.jp ([10.0.50.75])
	by fgwmail6.fujitsu.co.jp (Fujitsu Gateway) with ESMTP id n7KDtLc3026551
	for <netdev@vger.kernel.org> (envelope-from uchiyama.toru@jp.fujitsu.com);
	Thu, 20 Aug 2009 22:55:21 +0900
Received: from smail (m5 [127.0.0.1])
	by outgoing.m5.gw.fujitsu.co.jp (Postfix) with ESMTP id 0C25A45DE4F
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:21 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (s5.gw.fujitsu.co.jp [10.0.50.95])
	by m5.gw.fujitsu.co.jp (Postfix) with ESMTP id DF72C45DE4E
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:20 +0900 (JST)
Received: from s5.gw.fujitsu.co.jp (localhost.localdomain [127.0.0.1])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id C55B11DB8038
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:20 +0900 (JST)
Received: from m021.s.css.fujitsu.com (m021.s.css.fujitsu.com [10.0.81.61])
	by s5.gw.fujitsu.co.jp (Postfix) with ESMTP id 7CD001DB8043
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:17 +0900 (JST)
Received: from m021.css.fujitsu.com (m021 [127.0.0.1])
	by m021.s.css.fujitsu.com (Postfix) with ESMTP id 6A692180C1
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:17 +0900 (JST)
Received: from [127.0.0.1] (uchiyama.utsfd.cs.fujitsu.co.jp [10.24.19.76])
	by m021.s.css.fujitsu.com (Postfix) with ESMTP id 5187B180B9
	for <netdev@vger.kernel.org>; Thu, 20 Aug 2009 22:55:17 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch solves the problem that the Oops(BUG_ON) occurs by rmmod.

	# rmmod gianfar_driver
	------------[ cut here ]------------
	Kernel BUG at c01fec48 [verbose debug info unavailable]
	Oops: Exception in kernel mode, sig: 5 [#1]
	MPC837x MDS
	Modules linked in: gianfar_driver(-) usb_storage scsi_wait_scan
	NIP: c01fec48 LR: c01febf4 CTR: c01feba8
	REGS: dec5bd60 TRAP: 0700   Tainted: G        W   (2.6.31-rc2)
	MSR: 00029032 <EE,ME,CE,IR,DR>  CR: 22000424  XER: 20000000
	TASK = dec4cac0[1135] 'rmmod' THREAD: dec5a000
	GPR00: 00000002 dec5be10 dec4cac0 dfba1820 c035d444 c035d478 ffffffff 00000000
	GPR08: 0000002b 00000001 dfba193c 00000001 22000424 10019b34 1ffcb000 00000000
	GPR16: 10012008 00000000 bf82ebe0 100017ec bf82ebec bf82ebe8 bf82ebd0 00000880
	GPR24: 00000000 bf82ebf0 c03532f0 c03532e4 c036b594 dfba183c dfba1800 dfba1820
	NIP [c01fec48] free_netdev+0xa0/0xb8
	LR [c01febf4] free_netdev+0x4c/0xb8
	Call Trace:
	[dec5be10] [c01febf4] free_netdev+0x4c/0xb8 (unreliable)
	[dec5be30] [e105f290] gfar_remove+0x50/0x68 [gianfar_driver]
	[dec5be40] [c01ec534] of_platform_device_remove+0x30/0x44
	[dec5be50] [c0181760] __device_release_driver+0x68/0xc8
	[dec5be60] [c0181868] driver_detach+0xa8/0xac
	[dec5be80] [c0180814] bus_remove_driver+0x9c/0xd8
	[dec5bea0] [c0181efc] driver_unregister+0x60/0x98
	[dec5beb0] [c01ec650] of_unregister_driver+0x14/0x24
	[dec5bec0] [e10631bc] gfar_exit+0x18/0x4bc [gianfar_driver]
	[dec5bed0] [c0047584] sys_delete_module+0x16c/0x228
	[dec5bf40] [c00116bc] ret_from_syscall+0x0/0x38
	--- Exception: c01 at 0xff3669c
	    LR = 0x10000f34
	Instruction dump:
	409e0024 a07e00c0 7c63f050 4be74429 80010024 bba10014 38210020 7c0803a6
	4e800020 68000003 3160ffff 7d2b0110 <0f090000> 38000004 387e01f0 901e01d4
	---[ end trace 8c595bcd37230a0f ]---
	 localhost kernel: ------------[ cut here ]------------

Signed-off-by: uchiyama.toru@jp.fujitsu.com
---
 drivers/net/gianfar.c |    1 +
 1 files changed, 1 insertion(+)

diff --git a/drivers/net/gianfar.c b/drivers/net/gianfar.c
index f8ffcbf..25f1ca4 100644
--- a/drivers/net/gianfar.c
+++ b/drivers/net/gianfar.c
@@ -491,6 +491,7 @@ static int gfar_remove(struct of_device *ofdev)

 	dev_set_drvdata(&ofdev->dev, NULL);

+	unregister_netdev(dev);
 	iounmap(priv->regs);
 	free_netdev(priv->ndev);

--
