From: Manfred Spraul <manfred@colorfullife.com>
Subject: [PATCH] cleanup large frame handling for natsemi.c
Date: Sun, 20 Jun 2004 14:14:59 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40D57FC3.9040008@colorfullife.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi,

The DP83815/6 by default rejects frames longer that 1518 bytes 
(including crc). This means that a special flag must be set for 8021q - 
otherwise mtu sized packets are dropped.
The current driver enables this flag only if the buffer size is above 
1536 bytes - this is wrong. Additionally, the nic writes up to two bytes 
behind the indicated end of the buffer. This is not documented, thus 
I've added 64 bytes - just to be safe.
The patch also removes RX_OFFSET from the rx buffer allocation: The nic 
can only receive to 32-bit aligned addresses, it's a left over from a 
skeleton driver.

Jeff, could you apply it? I've stress tested vlan for an hour with 
tbench and parallel kernel compiles, not obvious problems.

--
    Manfred
