From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: Aggregated TX performance
Date: Wed, 27 Nov 2002 19:20:10 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <15845.3290.483532.218491@robur.slu.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: jamal <hadi@cyberus.ca>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


We discussed this. Below is a recent experiment... 


Aggregated TX performance test 2.5.47 SMP w. 2 x E1000 82546 (dual) 4.4.12-k1 
+ NAPI fixes for e1000 sent to lkml. SuperMicro 370 DL3 2x PIII @ 933 MHz.

Setup. (w. pktgen)
CPU0 transmitted on eth0 and eth1. 
CPU1 transmitted on eth2.


1) "Vanilla" setup no affinity and "full" kmalloc/kfree for each packet.
2)  As 1. irq affinity were set so interrupt go to resp. CPU.
3)  As 2. and pktgen used it's clone_skb behavior. In practice no 
    kmalloc's and kfree just doing a decrement.

Results in kpps.

Setup     1        2         3
===============================
eth0     182      220       466
eth1     182      220       466
eth2     314      429       791
         ---      ---      ----
Total    678      869      1723



Cheers.
						--ro
