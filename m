From: medhefgo@web.de
Subject: PROBLEM: freeze when resuming from suspend-to-ram
Date: Sun, 11 Nov 2012 20:47:45 +0100
Message-ID: <1560844.T75lq5MbC7@brinja>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: netdev@vger.kernel.org
To: venza@brownhat.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:63179 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752016Ab2KKTrt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 11 Nov 2012 14:47:49 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello, 

When resuming from suspend-to-ram the kernel freezes. Git bisect output below. 
When removing the sis900 module or if eth0 hasn't yet been brought up with "ip 
link set eth0 up", resuming works fine.

This is happening on a up-to-date Arch installation with kernel 3.6.6 and is 
still present in 3.7-rc5. Reverting the patch is possible and fixes the 
freezing.

Please let me know if more info is requried to fix this.

Thanks,
Jan

57d6d456cfb89264f87d24f52640ede23fdf12bd is the first bad commit
commit 57d6d456cfb89264f87d24f52640ede23fdf12bd
Author: Francois Romieu <romieu@fr.zoreil.com>
Date:   Tue Mar 13 11:14:17 2012 +0100

    sis900: stop using net_device.{base_addr, irq} and convert to __iomem.
    
    - pci_resource_start() can be removed from sis900_get_mac_addr() because
      the IO range is maped and stored into the device private struct early
      in the device probe function.
    - the driver contains a few direct accesses to low IO ports that forbid
      to re(#)define the usual out{l, w, b} macros.
    
    Signed-off-by: Francois Romieu <romieu@fr.zoreil.com>
    Cc: Daniele Venzano <venza@brownhat.org>

:040000 040000 f328a3383c1ff9b9ed16de7272b4c8a302ae2812 
44c07bfe1bd23b381fd407dfaa9591ed26165afd M      drivers
