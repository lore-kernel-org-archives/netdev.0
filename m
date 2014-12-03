From: Qin Chuanyu <qinchuanyu@huawei.com>
Subject: What's the concern about setting irq thread's policy as SCHED_FIFO
Date: Wed, 3 Dec 2014 16:06:59 +0800
Message-ID: <547EC4A3.6060408@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <linux-kernel@vger.kernel.org>
To: <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I am doing network performance test under suse11sp3 and intel 82599 nic,
Becasuse the softirq is out of schedule policy's control, so netserver 
thread couldn't always get 100% cpu usage, then packet dropped in kernel 
udp socket's receive queue.

In order to get a stable result, I did some patch in ixgbe driver and 
then use irq_thread instead of softirq to handle rx.
It seems work well, but irq_thread's SCHED_FIFO schedule policy cause 
that when the cpu is limited, netserver couldn't work at all.

So I change the irq_thread's schedule policy from SCHED_FIFO to 
SCHED_NORMAL, then the irq_thread could share the cpu usage with 
netserver thread.

the question is:
What's the concrete reason about setting irq thread's policy as SCHED_FIFO?
Except the priority affecting the cpu usage, any function would be 
broken if irq thread change to SCHED_NORMAL?
