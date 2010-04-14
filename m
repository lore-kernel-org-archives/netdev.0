From: Bryan Wu <bryan.wu@canonical.com>
Subject: Phylib polling when doing mdio_read will cause system response and
 transfer speed drop
Date: Tue, 13 Apr 2010 17:27:33 -0700
Message-ID: <4BC50BF5.7080700@canonical.com>
Reply-To: bryan.wu@canonical.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: afleming@freescale.com, davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Andy and David,

After I posted a patch to add phylib supporting in drivers/net/fec.c, we found 
performance drop regressions on Freescale i.MX51 babbage board.

Patch is 
http://git.kernel.org/?p=linux/kernel/git/davem/net-next-2.6.git;a=commitdiff;h=e6b043d512fa8d9a3801bf5d72bfa3b8fc3b3cc8.

Bug tracker is here: 
https://bugs.launchpad.net/ubuntu/+source/linux-fsl-imx51/+bug/546649

I found the root cause is the polling operation in the mdio_read function. When 
we transfer large files, we experienced many times of timeout issue. So I got 
several question here:
1. Need I return -ETIMEDOUT when polling timeout. If I don't return -ETIMEOUT, 
the performance improved a lot. And after check other drivers, some don't return 
anything, some return 0, some return negative value. What's the rule for this 
mdio_read polling timeout case.

2. How to do polling busy waiting? Normally, we won't buys wait very long in 
polling. But hardware is not perfect every time. Running cpu_relax() 10000 times 
in polling will cause our system response very bad when hardware don't set the 
flag as we expected. Maybe udelay(25) 10 times or msleep(1) 10 times is better 
than that.

I got a patch to recover this issue, 
http://kernel.ubuntu.com/git?p=roc/ubuntu-lucid.git;a=commitdiff;h=5d77e3409b319ca84183bf1d2fd158a9c864e03f.

Thanks a lot,
-- 
Bryan Wu <bryan.wu@canonical.com>
Kernel Developer    +86.138-1617-6545 Mobile
Ubuntu Kernel Team | Hardware Enablement Team
Canonical Ltd.      www.canonical.com
Ubuntu - Linux for human beings | www.ubuntu.com
