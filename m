From: Ben Greear <greearb@candelatech.com>
Subject: 2.4.21: bug report for tg3:  tx lockup when changing MTU
Date: Fri, 01 Aug 2003 15:54:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F2AEFBF.3040604@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I just noticed that if you change the MTU of a tg3 NIC, it will not work
untill you ifdown/ifup it.  This problem is repeatable on tg3, and does not
happen with the e1000 driver/cards.

I am setting the MTU via an ioctl call, not via ifconfig or something like
that.

When the tg3 is locked up, I see this on the console:

Aug  1 15:05:44 demo2 kernel: NETDEV WATCHDOG: eth5: transmit timed out
Aug  1 15:05:44 demo2 kernel: tg3: eth5: transmit timed out, resetting
Aug  1 15:05:44 demo2 kernel: tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
Aug  1 15:05:44 demo2 kernel: tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
Aug  1 15:05:44 demo2 kernel: tg3: tg3_stop_block timed out, ofs=c00 enable_bit=2
Aug  1 15:05:54 demo2 kernel: NETDEV WATCHDOG: eth5: transmit timed out
Aug  1 15:05:54 demo2 kernel: tg3: eth5: transmit timed out, resetting
Aug  1 15:05:54 demo2 kernel: tg3: tg3_stop_block timed out, ofs=2400 enable_bit=2
Aug  1 15:05:54 demo2 kernel: tg3: tg3_stop_block timed out, ofs=1400 enable_bit=2
...


Kernel is 2.4.21 + custom patches (which should not affect tg3).

lspci says the NIC is: Altima AC9100 (rev 15)

I will be happy to provide more information as needed.

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
