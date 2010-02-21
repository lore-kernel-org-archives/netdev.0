From: Ken Kawasaki <ken_kawasaki@spring.nifty.jp>
Subject: RE: [net-next 2.6 PATCH] net/pcmcia: convert to use
Date: Sun, 21 Feb 2010 14:04:49 +0900 (JST)
Message-ID: <19429651.85161266728689017.ken_kawasaki@spring.nifty.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-2022-jp"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.sv1.nifty.com ([220.209.183.60]:18591 "EHLO
	defg303p.nifty.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751048Ab0BUFWQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 21 Feb 2010 00:22:16 -0500
Received: from nfmsa301g.nifmail.jp (nfmsa301.nf.nifty.com [172.22.241.15])by defg303p.nifty.com with ESMTP id o1L55cgf027363
	for <netdev@vger.kernel.org>; Sun, 21 Feb 2010 14:05:38 +0900
Received: from aps515 (aps515 [172.22.128.195]) by nfmsa301g.nifmail.jp with ESMTP id o1L54n8I006796
	for <netdev@vger.kernel.org>; Sun, 21 Feb 2010 14:04:49 +0900
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

ioaddr is not used in set_address of xirc2ps_cs.c


+static void set_address(struct set_address_info *sa_info, char *addr)
+{
+	unsigned int ioaddr = sa_info->ioaddr;             <== HERE
+	int i;
+
+	for (i = 0; i < 6; i++) {
+		if (sa_info->reg_nr > 15) {
+			sa_info->reg_nr = 8;
+			sa_info->page_nr++;
+			SelectPage(sa_info->page_nr);
+		}
+		if (sa_info->mohawk)
+			PutByte(sa_info->reg_nr++, addr[5 - i]);
+		else
+			PutByte(sa_info->reg_nr++, addr[i]);
+	}
+}
+

