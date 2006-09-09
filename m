From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: HELP - NETDEV WATCHDOG tx timeouts
Date: Fri, 08 Sep 2006 22:03:20 -0500
Message-ID: <45022EF8.2020005@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932097AbWIIDDd@vger.kernel.org>
To: netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the bcm43xx driver, the code snippet shown below has a problem. When the synchronize_net 
statement is included, once every 200-300 passes through the code, the system will report a NETDEV 
WATCHDOG tx timeout for bcm43xx, even when the watchdog timeout is set to 30 sec. When the 
synchronize statement is removed, there are no errors, Except for lo, this is the only active 
network device on the system.

Is there something wrong with this structure? How can synchronize_net take that long?

Thanks, Larry

==============

        mutex_lock(...);
        netif_stop_queue(net_device);
        synchronize_net();               <================ problem ?
        spin_lock_irqsave(.....);
...... do some stuff on the hardware
        disable interrupts on device
        spin_unlock_irqrestore(.......);
        synchronize irq top/bottom halves
...... lengthy processing here
        spin_lock_irqsave(.....);
        tasklet_enable(.....);
        enable interrupts
...... more stuff with the hardware
        netif_wake_queue(net_device);
        spin_unlock_irqrestore(...);
        mutex_unlock(...);
