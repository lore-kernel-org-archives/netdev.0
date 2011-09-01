From: Valdis.Kletnieks@vt.edu
Subject: linux-next 20110831 - netconsole startup issue
Date: Thu, 01 Sep 2011 11:14:39 -0400
Message-ID: <5187.1314890079@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lennier.cc.vt.edu ([198.82.162.213]:50385 "EHLO
	lennier.cc.vt.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932129Ab1IAPOm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Sep 2011 11:14:42 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chasing a kernel panic in linux-next, and hit an unrelated issue
starting up netconsole that's bogging me down.

On linux-next-20110823, I had this:

[    7.078099] e1000e: Intel(R) PRO/1000 Network Driver - 1.5.1-k 
[    7.078102] e1000e: Copyright(c) 1999 - 2011 Intel Corporation.
[    7.078158] e1000e 0000:00:19.0: PCI INT A -> GSI 22 (level, low) -> IRQ 22
[    7.078171] e1000e 0000:00:19.0: setting latency timer to 64
[    7.078354] e1000e 0000:00:19.0: irq 46 for MSI/MSI-X
[    7.269439] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:70:de:b6:fd
[    7.269443] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    7.269469] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 4003FF-0FF
[    7.293569] netconsole: network logging started

Bring up the ethernet, then the console. Works great,

However, on -20110831, I get this:

[    0.983149] netconsole: local port 9909
[    0.983254] netconsole: local IP 128.173.14.107
[    0.983358] netconsole: interface 'eth0'
[    0.983461] netconsole: remote port 9909
[    0.983564] netconsole: remote IP 128.173.14.108
[    0.983668] netconsole: remote ethernet address 00:14:22:5a:79:d3
[    0.983776] netconsole: eth0 doesn't exist, aborting.
[    0.983897] netconsole: cleaning up
[    1.176429] e1000e 0000:00:19.0: eth0: (PCI Express:2.5GT/s:Width x1) 00:21:70:de:b6:fd
[    1.176557] e1000e 0000:00:19.0: eth0: Intel(R) PRO/1000 Network Connection
[    1.176688] e1000e 0000:00:19.0: eth0: MAC: 7, PHY: 8, PBA No: 4003FF-0FF

Whoops. No netconsole.

Even more annoying (and quite possibly related), the kernel is built with
CONFIG_NETCONSOLE_DYNAMIC. On -20110823, I have a /sys/kernel/config/netconsole
directory and can use it to configure netconsole on the fly.  However, on
-20110831, /sys/kernel/config is empty - no netconsole subdirectory.  So I
couldn't even boot to single-user, configure netconsole, and then continue to
multiuser and capture the crash.
