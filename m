From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in 8139too
Date: Mon, 15 Dec 2014 10:35:38 +0800
Message-ID: <000001d0180f$d0861a90$71924fb0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:34294 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750713AbaLOCfr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 21:35:47 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers 3.17.2, and find some potential bugs.

The target file is drivers/net/ethernet/realtek/8139too.c, which is used to
build 8139too.ko. I hope you can help me check my findings:
[1] In the normal process of 8139too, netif_napi_add is called in
rtl8139_init_one, but netif_napi_del is not called in rtl8139_remove_one.
However, many other ethernet card drivers call them in pairs, even in the
error handling paths, such as r8169 and igb.
[2] In the normal process of 8139too, pci_enable_device and
pci_disable_device are called in pairs in rtl8139_init_board(in
rtl8139_init_one) and rtl8139_remove_one. However, when pci_enable_device
has been called and pci_request_regions is failed in rtl8139_init_board,
"err_out" segment in rtl8139_init_board is executed immediately to exit, but
pci_disable_device is not called because "disable_dev_on_err = 0".

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Jia-Ju Bai
