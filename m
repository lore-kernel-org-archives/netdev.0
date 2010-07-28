From: Johannes Berg <johannes@sipsolutions.net>
Subject: local_bh_enable_ip warning with conntrack/forcedeth
Date: Wed, 28 Jul 2010 10:12:09 +0200
Message-ID: <1280304729.3684.11.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from he.sipsolutions.net ([78.46.109.217]:52260 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751886Ab0G1IMM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Jul 2010 04:12:12 -0400
Received: by sipsolutions.net with esmtpsa (TLS1.0:DHE_RSA_AES_256_CBC_SHA1:32)
	(Exim 4.72)
	(envelope-from <johannes@sipsolutions.net>)
	id 1Oe1kI-0002rl-Ib
	for netdev@vger.kernel.org; Wed, 28 Jul 2010 10:12:10 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a bit weird ... forcedeth uses dev_kfree_skb_any(), which gets
to dev_kree_skb_irq(), but then why consume_skb() which can't be called
in that context?

Or is the destructor check in dev_kfree_skb_irq() wrong?

[  446.375065] WARNING: at /home/johannes/sys/wireless-testing/kernel/softirq.c:143 local_bh_enable_ip+0xba/0x110()
[  446.375069] Hardware name: MacBook5,1
[  446.375172] Pid: 0, comm: swapper Not tainted 2.6.35-rc6-wl-48390-gb63b887-dirty #176
[  446.375175] Call Trace:
[  446.375178]  <IRQ>  [<ffffffff81046b5f>] warn_slowpath_common+0x7f/0xc0
[  446.375197]  [<ffffffff81046bba>] warn_slowpath_null+0x1a/0x20
[  446.375201]  [<ffffffff8104eb0a>] local_bh_enable_ip+0xba/0x110
[  446.375207]  [<ffffffff8149072e>] _raw_spin_unlock_bh+0x3e/0x50
[  446.375214]  [<ffffffffa08c249c>] destroy_conntrack+0xfc/0x150 [nf_conntrack]
[  446.375227]  [<ffffffff813db358>] nf_conntrack_destroy+0x68/0x100
[  446.375236]  [<ffffffff813a71b5>] skb_release_head_state+0xe5/0x120
[  446.375240]  [<ffffffff813a6de6>] __kfree_skb+0x16/0xa0
[  446.375244]  [<ffffffff813a6e8e>] consume_skb+0x1e/0x40
[  446.375249]  [<ffffffff813b4405>] dev_kfree_skb_irq+0xa5/0xb0
[  446.375258]  [<ffffffff813b443c>] dev_kfree_skb_any+0x2c/0x50
[  446.375262]  [<ffffffff81364be9>] nv_tx_done_optimized+0x59/0x220
[  446.375271]  [<ffffffff81367ffa>] nv_napi_poll+0x6a/0x330
[  446.375276]  [<ffffffff813b228b>] net_rx_action+0x12b/0x300
[  446.375280]  [<ffffffff8104ee34>] __do_softirq+0x114/0x3d0
[  446.375290]  [<ffffffff8100360c>] call_softirq+0x1c/0x50
[  446.375294]  [<ffffffff8100500d>] do_softirq+0x7d/0xb0
[  446.375298]  [<ffffffff8104e8d5>] irq_exit+0x95/0xa0
[  446.375302]  [<ffffffff8100450c>] do_IRQ+0x7c/0xf0
[  446.375306]  [<ffffffff81490d13>] ret_from_intr+0x0/0xf



