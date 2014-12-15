From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in 3c59x
Date: Mon, 15 Dec 2014 09:41:58 +0800
Message-ID: <000f01d01808$525c2580$f7147080$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m50-132.163.com ([123.125.50.132]:41372 "EHLO m50-132.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750770AbaLOBmJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 20:42:09 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers 3.17.2. 
The target file is drivers/net/ethernet/3com/3c59x.c, which is used to build
3c59x.ko. I hope you can help me check my findings:
[1] The function vortex_up is called by vortex_open when initializing the
ethernet card driver. But when vortex_up is failed, which means that it
returns the error value, "out" segment is executed immediately to halt the
process. However, the resources allocated by __netdev_alloc_skb in
vortex_open are not released by dev_kfree_skb when vortex_up is failed.
[2] As shown in [1], one reason that vortex_up is failed is that
pci_enable_device is failed(return the error value) in vortex_up, and
"err_out" segment is executed immediately to return.
Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.
