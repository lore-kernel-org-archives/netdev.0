From: Chuck Ebbert <cebbert@redhat.com>
Subject: e1000: assertion hit in e1000_clean(), kernel 2.6.21.1
Date: Fri, 18 May 2007 18:33:44 -0400
Message-ID: <464E29C8.9090905@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Netdev <netdev@vger.kernel.org>
To: Auke Kok <auke-jan.h.kok@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([66.187.233.31]:34774 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755911AbXERWdt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 May 2007 18:33:49 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

We have several reports now of hitting this assertion in
netif_rx_complete(), inlined in e1000_clean():

        BUG_ON(!test_bit(__LINK_STATE_RX_SCHED, &dev->state));

 [<c0431162>] __queue_work+0x51/0x5e
 [<c059eea1>] et_rx_action+0x94/0x185
 [<c042837d>] __do_softirq+0x5d/0xba
 [<c0407837>] do_softirq+0x59/0xb1
 [<c04281e9>] local_bh_enable_ip+0x35/0x40
 [<c059e46b>] dev_open+0x44/0x62
 [<c059ce8c>] dev_change_flags+0x46/0xe3
 [<c05d9e09>] devinet_ioctl+0x250/0x56a

The second function is "net_rx_action", corrupted
by the serial connection. 

The source file has four extra lines at the top because of a
trivial wireless patch, so 898 in that code is really 894 in
the stock kernel.

https://bugzilla.redhat.com/bugzilla/show_bug.cgi?id=240339
