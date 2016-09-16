From: Julia Lawall <julia.lawall@lip6.fr>
Subject: [net-next:master 58/374] drivers/net/ethernet/amazon/ena/ena_netdev.c:3026:1-11:
 Use setup_timer function for function on line 3028.
Date: Fri, 16 Sep 2016 15:39:09 +0200 (CEST)
Message-ID: <alpine.DEB.2.10.1609161537560.3049@hadrien>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kbuild-all@01.org
To: Netanel Belgazal <netanel@annapurnalabs.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail3-relais-sop.national.inria.fr ([192.134.164.104]:48604
        "EHLO mail3-relais-sop.national.inria.fr" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1757260AbcIPNjN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 16 Sep 2016 09:39:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Setup_timer could be used instead of the cvall to init_timer and the
initializations of the function and data fields.

julia


tree:   https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git master
head:   84ce3da1bfd6fd12fce3cd06691e405a36f72cde
commit: 1738cd3ed342294360d6a74d4e58800004bff854 [58/374] net: ena: Add a driver for Amazon Elastic Network Adapters (ENA)
:::::: branch date: 5 hours ago
:::::: commit date: 5 weeks ago

>> drivers/net/ethernet/amazon/ena/ena_netdev.c:3026:1-11: Use setup_timer function for function on line 3028.

git remote add net-next https://git.kernel.org/pub/scm/linux/kernel/git/davem/net-next.git
git remote update net-next
git checkout 1738cd3ed342294360d6a74d4e58800004bff854
vim +3026 drivers/net/ethernet/amazon/ena/ena_netdev.c

1738cd3e Netanel Belgazal 2016-08-10  3020  	INIT_WORK(&adapter->suspend_io_task, ena_device_io_suspend);
1738cd3e Netanel Belgazal 2016-08-10  3021  	INIT_WORK(&adapter->resume_io_task, ena_device_io_resume);
1738cd3e Netanel Belgazal 2016-08-10  3022  	INIT_WORK(&adapter->reset_task, ena_fw_reset_device);
1738cd3e Netanel Belgazal 2016-08-10  3023
1738cd3e Netanel Belgazal 2016-08-10  3024  	adapter->last_keep_alive_jiffies = jiffies;
1738cd3e Netanel Belgazal 2016-08-10  3025
1738cd3e Netanel Belgazal 2016-08-10 @3026  	init_timer(&adapter->timer_service);
1738cd3e Netanel Belgazal 2016-08-10  3027  	adapter->timer_service.expires = round_jiffies(jiffies + HZ);
1738cd3e Netanel Belgazal 2016-08-10 @3028  	adapter->timer_service.function = ena_timer_service;
1738cd3e Netanel Belgazal 2016-08-10  3029  	adapter->timer_service.data = (unsigned long)adapter;
1738cd3e Netanel Belgazal 2016-08-10  3030
1738cd3e Netanel Belgazal 2016-08-10  3031  	add_timer(&adapter->timer_service);

---
0-DAY kernel test infrastructure                Open Source Technology Center
https://lists.01.org/pipermail/kbuild-all                   Intel Corporation
