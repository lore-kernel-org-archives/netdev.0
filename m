From: Abhijit Menon-Sen <ams@toroid.org>
Subject: tc filter add ... fw ... action drop
Date: Wed, 18 Jul 2007 08:58:41 +0530
Message-ID: <20070718032841.GA14874@toroid.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: shemminger@osdl.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fugue.toroid.org ([85.10.196.113]:4919 "EHLO fugue.toroid.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754012AbXGRD63 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 17 Jul 2007 23:58:29 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi.

Is it a bug that:

  # tc filter add dev eth0 parent 1: protocol ip prio 0 handle 0xfffffff
    fw police rate 1 burst 1 mpu 0 mtu 1 action drop
                                         ^^^^^^^^^^^
creates a filter that looks like:

  # tc filter ls dev eth0
  filter parent 1: protocol ip pref 49152 fw 
  filter parent 1: protocol ip pref 49152 fw handle 0xfffffff police 0x1
  rate 0bit burst 0b mtu 1b action reclassify
                            ^^^^^^^^^^^^^^^^^
  ref -543190236 bind 4

(which reclassifies and thus lets 0xfffffff-marked packets through).

I'm pretty sure this used to work under 2.4.x (though I no longer have a
2.4 box to test with), but it hasn't worked on any of the 2.6.x kernels
I've tried (with both iproute2-ss060323 and 070710).

I haven't been able to find anything that suggests this change is
intentional. If it's not immediately obvious to anyone what the
problem is, I could try to track it down.

-- ams
