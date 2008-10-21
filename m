From: Andi Kleen <andi@firstfloor.org>
Subject: Current git r8169 driver often misses link at boot
Date: Tue, 21 Oct 2008 21:11:58 +0200
Message-ID: <20081021191158.GA16262@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: romieu@fr.zoreil.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from one.firstfloor.org ([213.235.205.2]:51630 "EHLO
	one.firstfloor.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755151AbYJUTL7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Oct 2008 15:11:59 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a nfsroot test system with a r8169 NIC. Since I updated
from 2.6.27 to 2.6.27-git10 it doesn't find its root fs in 2 out of
3 boots. The r8169 gets detected, but there is never
a message that it finds the link in the failed cases:

r8169 Gigabit Ethernet driver 2.3LK-NAPI loaded
r8169 0000:02:00.0: PCI INT A -> GSI 18 (level, low) -> IRQ 18
r8169 0000:02:00.0: setting latency timer to 64
r8169 0000:02:00.0: irq 45 for MSI/MSI-X
eth0: RTL8168b/8111b at 0xffffc2000035a000, 00:00:00:00:00:00, XID 38000000 IRQ 
45

I tried to revert back to the 2.6.27 r8169.c and that fixed
the problem here. Didn't see a hang so far in 4 boots with
the old driver.

I also originally thought it was related to netconsole, but even
with that removed the problem still happens.

-Andi

-- 
ak@linux.intel.com
