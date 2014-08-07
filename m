From: Jisheng Zhang <jszhang@marvell.com>
Subject: Weird NET_RX softirq behavior
Date: Thu, 7 Aug 2014 17:10:50 +0800
Message-ID: <20140807171050.77819b10@xhacker>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Content-Transfer-Encoding: 7bit
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi list,

I observed one weird NET_RX softirq behavior:


1. CONFIG_RPS=y in kernel config file.

2. only one netdev in the system: eth0. eth0 only has one interrupt which is
all handled by CPU0. eth0 doesn't support RFS_ACCEL

"cat /proc/interrupts" shows 

~ # cat /proc/interrupts 
           CPU0       CPU1       CPU2       CPU3       
...
 49:         52          0          0          0       GIC  mmc1
 52:         53          0          0          0       GIC  mmc2
 56:     430365          0          0          0       GIC  eth0
 60:         61          0          0          0       GIC  mmc0
...

3. RPS and RFS remains disabled as default.

~ # ls /sys/class/net/eth0/queues/
rx-0  rx-1  rx-2  rx-3  tx-0
~ # cat /sys/class/net/eth0/queues/rx-*/rps_cpus
0
0
0
0
~ # cat /proc/sys/net/core/rps_sock_flow_entries
0
~ # cat /sys/class/net/eth0/queues/rx-*/rps_flow_cnt
0
0
0
0

4. But NET_RX seems abnormal
~ # cat /proc/softirqs 
                    CPU0       CPU1       CPU2       CPU3       
          HI:          0          0          0          0
       TIMER:      92386        767        367        263
      NET_TX:       6338          0          0          1
      NET_RX:     445587        322        983          0
       BLOCK:          0          0          0          0
BLOCK_IOPOLL:          0          0          0          0
     TASKLET:        150          0          0          0
       SCHED:      31414        490        275        179
     HRTIMER:          1          0          0          0
         RCU:      49029        570        285        182

I'm expecting NET_RX under CPU1, 2, 3 should be zero. Any suggestions
about this abnormal behavior?

Thanks in advance,
Jisheng
