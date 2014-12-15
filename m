From: "Jia-Ju Bai" <baijiaju1990@163.com>
Subject: Potential bugs found in via-rhine
Date: Mon, 15 Dec 2014 10:46:40 +0800
Message-ID: <000201d01811$5af37640$10da62c0$@163.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from m12-15.163.com ([220.181.12.15]:47800 "EHLO m12-15.163.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751181AbaLOCqw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 14 Dec 2014 21:46:52 -0500
Content-Language: zh-cn
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Recently I test linux device drivers 3.17.2, and find some potential bugs.
The target file is drivers/net/ethernet/via/via-rhine, which is used to
build via-rhine.ko. I hope you can help me check my findings:

[1] In the normal process, netif_napi_add is called in
rhine_init_one_common, but netif_napi_del is not called in
rhine_remove_one_pci. However, many other ethernet card drivers call them in
pairs, even in the error handling paths, such as r8169 and igb.
[2] In my running test, if dma_mapping_error in alloc_rbufs is failed,
system crash occurs when executing netif_receive_skb in rhine_napipoll, but
I can not find the specific reason.

Could you help me check these findings? Thank you very much, and I'm looking
forward to your reply.

--
Jia-Ju Bai
