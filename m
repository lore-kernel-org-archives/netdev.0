From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in e100
Date: Mon, 15 Dec 2014 11:24:40 +0800
Message-ID: <000001d01816$a984e370$fc8eaa50$@163.com>
References: <001101d01809$b58ccbe0$20a663a0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:44001 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750765AbaLODYw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 22:24:52 -0500
In-Reply-To: <001101d01809$b58ccbe0$20a663a0$@163.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers in Linux 3.17.2, and find some
potential bugs. 

e100 driver:
The target file is drivers/net/ethernet/intel/e100.c, which is used to build
e100.ko. I hope you can help me check my findings:
[1] The function pci_pool_create is called by e100_probe when initializing
the ethernet card driver. But when pci_pool_create is failed, which means
that it returns NULL to nic->cbs_pool, the system crash will happen. Because
pci_pool_alloc (in e100_alloc_cbs in e100_up in e100_open) need to use
nic->cbs_pool to allocate the resource, but it is NULL. I suggest that a
check can be added in the code to detect whether pci_pool_create returns
NULL.
[2] In the normal process, netif_napi_add is called in e100_probe, but
netif_napi_del is not called in e100_remove. However, many other ethernet
card drivers call them in pairs, even in the error handling paths, such as
r8169 and igb.

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Jia-Ju Bai
