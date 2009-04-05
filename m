From: Jesper Krogh <jesper@krogh.cc>
Subject: eth0: too many iterations (16) in nv_nic_irq.
Date: Sun, 05 Apr 2009 10:19:35 +0200
Message-ID: <49D86997.6010304@krogh.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Joe Korty <joe.korty@ccur.com>,
	Ayaz Abdulla <aabdulla@nvidia.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2605ds1-ynoe.1.fullrate.dk ([90.184.12.24]:41937 "EHLO
	shrek.krogh.cc" rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751654AbZDEITh (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Apr 2009 04:19:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I have a 2.6.29 kernel which fills up the "dmesg-buffer" with these:

eth0: too many iterations (16) in nv_nic_irq.

$ dmesg | grep -c "too many iterations"
1986

I have seen the commit below.. is the fix just to set the limit to 30 
instead? or is there a "real bug" underneath?

commit dccd547e2bf2c01a13c967ae03a705338394fad6
Author: Joe Korty <joe.korty@ccur.com>
Date:   Wed Oct 29 14:22:16 2008 -0700

     forcdeth: increase max_interrupt_work

     This eliminates the following often-generated warning from my 64 bit
     Opteron SMP test stand:

         eth0: too many iterations (6) in nv_nic_irq

     According to the web, the problem is that the forcedeth driver has a
     too-low value for max_interrupt_work.  Grepping the kernel I see that
     forcedeth has the second lowest value of all ethernet drivers (ie, 6).
     Most are in the 20-40 range.  So this patch increases this a bit, 
from 6
     to 15 (at 15 forcedeth becomes the driver with third-lowest
     max_interrupt_work value).

     My test stand, which used to print out the above warnings repetitively
     whenever it was under heavy net load, no longer does so.

     Signed-off-by: Joe Korty <joe.korty@ccur.com>
     Cc: Ayaz Abdulla <aabdulla@nvidia.com>
     Cc: Jeff Garzik <jeff@garzik.org>
     Signed-off-by: Andrew Morton <akpm@linux-foundation.org>
     Signed-off-by: Jeff Garzik <jgarzik@redhat.com>
