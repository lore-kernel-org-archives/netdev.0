From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in ne2k-pci+8390
Date: Sat, 22 Nov 2014 11:51:15 +0800
Message-ID: <000001d00607$90e5ee70$b2b1cb50$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-16.163.com ([220.181.12.16]:45760 "EHLO m12-16.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752687AbaKVDv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 21 Nov 2014 22:51:29 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Sir,
I'm very sorry to trouble you. 
Recently I test 15 linux device drivers and find some potential bugs both in
Linux 3.8.6 and Linux 3.17.2. 

The target file is drivers/net/ethernet/8390/ne2k-pci.c, which is used to
build ne2k-pci.ko. I hope you can help me check my findings:
[1] The function request_region is called by ne2k_pci_init_one when
initializing the ethernet card driver. But when request_region is failed,
which means that it returns the error value, ne2k_pci_init_one returns
immediately to halt the process. However, because pci_enable_device has been
called before request_region in ne2k_pci_init_one, pci_disable_device should
be called before exiting. When the driver works normally, pci_enable_device
and pci_disable_device are called in pairs in ne2k_pci_init_one and
ne2k_pci_remove_one. Moreover, other ethernet card drivers call
pci_enable_device and pci_disable_device in pairs in error handling paths,
such as r8169 and sky2.
[2] The similar problem to [1] occurs when alloc_ei_netdev is failed in
ne2k_pci_init_one.
[3] The similar problem to [1] occurs when register_netdev is failed in
ne2k_pci_init_one.

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Best wishes!
Jia-Ju Bai
E-mail: baijiaju1990@163.com
Department of Computer Science and Technology, Tsinghua University
Address: Room 1-417, West Main, Tsinghua University, Haidian District,
Beijing, 100084, China.
