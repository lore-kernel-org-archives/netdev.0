From: Kirill Kuvaldin <kuvkir@epsmu.com>
Subject: via-rhine: Transmit timed out problem
Date: Fri, 22 Jun 2007 16:18:04 +0400
Message-ID: <20070622121804.GB14554@zetta.epsmu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org, rl@hellgate.ch
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.qwerty.ru ([87.240.2.134]:47828 "EHLO smtp.qwerty.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752640AbXFVMaW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 22 Jun 2007 08:30:22 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

I'm experiencing a strange problem with a via rhine network card on Ubuntu 
7.04 (2.6.20-16-generic #2 SMP). The hardware seemed to come into an
inconsistent state, since rmmod'ing and modprobe'ing the via-rhine driver 
back didn't help. 

After the problem had appeared, I could see the following in dmesg:

[ 8601.971189] irq 21: nobody cared (try booting with the "irqpoll"
option)
[ 8601.971214]  [<c01543a4>] __report_bad_irq+0x24/0x80
[ 8601.971229]  [<c015465e>] note_interrupt+0x25e/0x290
[ 8601.971238]  [<c01538d0>] handle_IRQ_event+0x30/0x60
[ 8601.971245]  [<c0154f91>] handle_fasteoi_irq+0xc1/0xf0
[ 8601.971252]  [<c0105b70>] do_IRQ+0x40/0x80
[ 8601.971259]  [<c0104233>] common_interrupt+0x23/0x30
[ 8601.971269]  [<c01012b6>] mwait_idle_with_hints+0x46/0x60
[ 8601.971276]  [<c0101409>] cpu_idle+0x49/0xd0
[ 8601.971289]  =======================
[ 8601.971291] handlers:
[ 8601.971293] [<f887ff10>] (usb_hcd_irq+0x0/0x60 [usbcore])
[ 8601.971311] [<f88a7dd0>] (rhine_interrupt+0x0/0xb80 [via_rhine])
[ 8601.971324] Disabling IRQ #21
[ 8637.970985] NETDEV WATCHDOG: eth0: transmit timed out
[ 8637.971135] eth0: Transmit timed out, status 1003, PHY status 786d,
resetting
[ 8637.971163] via-rhine: Reset not complete yet. Trying harder.
[ 8637.971754] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[ 8640.749432] via-rhine: Reset not complete yet. Trying harder.
[ 8640.750018] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[ 8644.746689] NETDEV WATCHDOG: eth0: transmit timed out
[ 8644.746838] eth0: Transmit timed out, status 0003, PHY status 786d,
resetting
[ 8644.747446] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[ 8648.743327] NETDEV WATCHDOG: eth0: transmit timed out
[ 8648.743476] eth0: Transmit timed out, status 0003, PHY status 786d,
resetting
[ 8648.744083] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[ 8651.070635] eth0: no IPv6 routers present
[ 8670.723818] NETDEV WATCHDOG: eth0: transmit timed out
[ 8670.723968] eth0: Transmit timed out, status 0003, PHY status 786d,
resetting
[ 8670.723995] via-rhine: Reset not complete yet. Trying harder.
[ 8670.724578] eth0: link up, 100Mbps, full-duplex, lpa 0x45E1
[ 8726.668036] NETDEV WATCHDOG: eth0: transmit timed out


The interrupt seemed to be unhandled and got disabled by the kernel
then. The transmission seemed to time out for some reason (probably, the
hardware got into an inconsistent state?).


Some related information:

kuvkir@coreduo:~% lspci |grep -i rhine
00:12.0 Ethernet controller: VIA Technologies, Inc. VT6102 [Rhine-II]
(rev 7c)
kuvkir@coreduo:~% uname -a
Linux coreduo 2.6.20-16-generic #2 SMP Thu Jun 7 20:19:32 UTC 2007 i686
GNU/Linux
kuvkir@coreduo:~% dmesg|grep rhine
[    2.982700] via-rhine.c:v1.10-LK1.4.2 Sept-11-2006 Written by Donald
Becker

Is that information sufficient for debug? Let me know if you need
any additional data.


  Kirill

