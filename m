From: Tsutomu Fujii <t-fujii@nb.jp.nec.com>
Subject: Bonding in active-backup mode with arp monitoring on Xen
Date: Thu, 27 Mar 2008 21:49:04 +0900
Message-ID: <47EB97C0.5010203@nb.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from TYO202.gate.nec.co.jp ([202.32.8.206]:39752 "EHLO
	tyo202.gate.nec.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755648AbYC0MtJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Mar 2008 08:49:09 -0400
Received: from mailgate3.nec.co.jp (mailgate53.nec.co.jp [10.7.69.162])
	by tyo202.gate.nec.co.jp (8.13.8/8.13.4) with ESMTP id m2RCn7Fq021565
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 21:49:07 +0900 (JST)
Received: (from root@localhost) by mailgate3.nec.co.jp (8.11.7/3.7W-MAILGATE-NEC)
	id m2RCn7E25391 for netdev@vger.kernel.org; Thu, 27 Mar 2008 21:49:07 +0900 (JST)
Received: from kaishu.jp.nec.com (kaishu.jp.nec.com [10.26.220.5])
	by mailsv3.nec.co.jp (8.13.8/8.13.4) with ESMTP id m2RCn6GK024108
	for <netdev@vger.kernel.org>; Thu, 27 Mar 2008 21:49:06 +0900 (JST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

A little while ago I posted a patch to fix the communication problem
when bonding was used in active-backup mode with arp monitoring on Xen
guest OS.

http://marc.info/?l=linux-netdev&m=119362063924723&w=2

I have rebased the patch to the latest 2.6.25-rc7 kernel.

I've confirmed that active-backup mode works fine with arp monitoring
with this patch.

Thanks.

--
Tsutomu fujii

--- a/drivers/net/bonding/bond_main.c	2008-03-26 10:38:14.000000000 +0900
+++ b/drivers/net/bonding/bond_main.c	2008-03-27 19:39:06.000000000 +0900
@@ -3003,7 +3003,7 @@
 		/* the current slave must tx an arp to ensure backup slaves
 		 * rx traffic
 		 */
-		if (slave && bond_has_ip(bond)) {
+		if (slave && IS_UP(slave->dev)) {
 			bond_arp_send_all(bond, slave);
 		}
 	}
