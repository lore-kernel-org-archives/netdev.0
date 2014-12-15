From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in igb
Date: Mon, 15 Dec 2014 11:22:08 +0800
Message-ID: <000001d01816$4feca3c0$efc5eb40$@163.com>
References: <005601d0180e$02a5bf50$07f13df0$@163.com> <005801d0180e$6a672de0$3f3589a0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-17.163.com ([220.181.12.17]:35094 "EHLO m12-17.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750814AbaLODWP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 22:22:15 -0500
In-Reply-To: <005801d0180e$6a672de0$3f3589a0$@163.com>
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers in Linux 3.17.2, and find some
potential bugs.

igb driver:
[1] In the normal process of igb, pci_enable_pcie_error_reporting and
pci_disable_pcie_error_reporting is called in pairs in igb_probe and
igb_remove. However, when pci_enable_pcie_error_reporting has been called
and alloc_etherdev_mqs in igb_probe is failed, "err_alloc_etherdev" segment
in igb_probe is executed immediately to exit, but
pci_disable_pcie_error_reporting is not called.
[2] The same situation with [1] happens when pci_iomap in igb_probe is
failed.
[3] The same situation with [1] happens when igb_sw_init in igb_probe is
failed.
[4] The same situation with [1] happens when register_netdev in igb_probe is
failed.
[5] The same situation with [1] happens when igb_init_i2c in igb_probe is
failed.
[6] The function kcalloc is called by igb_sw_init when initializing the
ethernet card driver, but kfree is not called when register_netdev in
igb_probe is failed, which may cause memory leak.
[7] The same situation with [6] happens when igb_init_i2c in igb_probe is
failed.
[8] The same situation with [6] happens when kzalloc in igb_alloc_q_vector
is failed.
[9] The same situation with [6] happens when igb_alloc_q_vector in
igb_alloc_q_vectors is failed.
[10] When igb_init_i2c in igb_probe is failed, igb_enable_sriov is called in
igb_probe_vfs, but igb_disable_sriov is not called.
[11] The same situation with [10] happens when register_netdev in igb_probe
is failed.

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Jia-Ju Bai
