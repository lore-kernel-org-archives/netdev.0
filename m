From: Holger Freyther <zecke@selfish.org>
Subject: r8169 not workin on resume due allocation failure
Date: Wed, 8 Sep 2010 03:44:07 +0000 (UTC)
Message-ID: <loom.20100908T054044-695@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:42872 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751147Ab0IHDoT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 7 Sep 2010 23:44:19 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1OtBa4-0002TB-2I
	for netdev@vger.kernel.org; Wed, 08 Sep 2010 05:44:17 +0200
Received: from 123-192-162-165.dynamic.kbronet.com.tw ([123.192.162.165])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 05:44:16 +0200
Received: from zecke by 123-192-162-165.dynamic.kbronet.com.tw with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 05:44:16 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,

I'm using the r8169 module on my notebook and after a couple of days
of running with suspend/resume the networking stops working. I have
the dmesg output at the end of the email. From my understanding this
is due that on suspend the interface will be brought down, the rx buffers
are freed and that on resume it is not possible to allocate a continous
buffer for the sizes required.

My approach to handle this would be to add an option to not free the
buffers until the module is unloaded and guard this with an option. Is
that an acceptable solution?


NetworkManager: page allocation failure. order:3, mode:0x4020
Pid: 1291, comm: NetworkManager \n
Not tainted 2.6.35.4-12.fc14.i686.PAE #1
Call Trace:
 [<c07e2197>] ? printk+0x25/0x2e
 [<c04c1af6>] __alloc_pages_nodemask+0x5bc/0x62f
 [<c04c1b83>] __get_free_pages+0x1a/0x2c
 [<c04e7bd6>] __kmalloc_track_caller+0x32/0x144
 [<c07465fb>] ? __netdev_alloc_skb+0x1b/0x36
 [<c07464fd>] __alloc_skb+0x59/0x100
 [<c07465fb>] __netdev_alloc_skb+0x1b/0x36
 [<f9796a8f>] rtl8169_rx_fill+0x99/0x132 [r8169]
 [<f9797913>] rtl8169_init_ring+0x66/0x96 [r8169]
 [<f9797e98>] rtl8169_open+0x7f/0x1d7 [r8169]
 [<c0750b04>] __dev_open+0x79/0xaa
 [<c0750cf9>] __dev_change_flags+0x98/0x10d
 [<c0750dde>] dev_change_flags+0x18/0x44
 [<c075976f>] do_setlink+0x253/0x52e


