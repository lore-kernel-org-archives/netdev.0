From: Ben Greear <greearb@candelatech.com>
Subject: locked up 4-port Intel NIC with RH 8.0 and eepro100 driver
Date: Tue, 25 Feb 2003 13:42:38 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3E5BE34E.4030500@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: eepro list <eepro100@scyld.com>,
   "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Seems transmit no longer works out of the second interface...
Only the first two ports have a cable attached,
each to a tg3 GigE NIC with a cross-over cable.  It ran for
about 3 days at 50Mbps bi-directional on two ports before locking
up.  The machine was at 100% CPU utilization this entire time.  After
stopping traffic for 1 minute, and then starting it again, it started
working again.  The error I was seeing indicated trying to write to the socket
would block (EAGAIN).  For what it's worth, I saw similar problems on
this machine with an rtl8139too when connected to a 10bt hub, but in
that case the rtldiag showed more problems, and lockups happened in
3-8 hours...

If this line means nothing, then it's possibly a user-space problem.

  The Command register has an unprocessed command 0c00(?!).


dmesg output:

eepro100.c:v1.09j-t 9/29/99 Donald Becker http://www.scyld.com/network/eepro100.html
eepro100.c: $Revision: 1.36 $ 2000/11/17 Modified by Andrey V. Savochkin <saw@saw.sw.com.sg> and others
divert: allocating divert_blk for eth3
eth3: OEM i82557/i82558 10/100 Ethernet, 00:30:F7:03:C5:4A, IRQ 11.
   Receiver lock-up bug exists -- enabling work-around.
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555.
   General self-test: passed.
   Serial sub-system self-test: passed.
   Internal registers self-test: passed.
   ROM checksum self-test: passed (0xd0a6c714).
   Receiver lock-up workaround activated.
divert: allocating divert_blk for eth4
eth4: OEM i82557/i82558 10/100 Ethernet, 00:30:F7:03:C5:4B, IRQ 11.
   Receiver lock-up bug exists -- enabling work-around.
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555.
   General self-test: passed.
   Serial sub-system self-test: passed.
   Internal registers self-test: passed.
   ROM checksum self-test: passed (0xd0a6c714).
   Receiver lock-up workaround activated.
divert: allocating divert_blk for eth5
eth5: OEM i82557/i82558 10/100 Ethernet, 00:30:F7:03:C5:4C, IRQ 10.
   Receiver lock-up bug exists -- enabling work-around.
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555.
   General self-test: passed.
   Serial sub-system self-test: passed.
   Internal registers self-test: passed.
   ROM checksum self-test: passed (0xd0a6c714).
   Receiver lock-up workaround activated.
divert: allocating divert_blk for eth6
eth6: OEM i82557/i82558 10/100 Ethernet, 00:30:F7:03:C5:4D, IRQ 5.
   Receiver lock-up bug exists -- enabling work-around.
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555.
   General self-test: passed.
   Serial sub-system self-test: passed.
   Internal registers self-test: passed.
   ROM checksum self-test: passed (0xd0a6c714).
   Receiver lock-up workaround activated.


Here is the eepro-diag output:

eepro100-diag.c:v2.02 7/19/2000 Donald Becker (becker@scyld.com)
  http://www.scyld.com/diag/index.html
Index #1: Found a Intel 82559ER EtherExpressPro/100+ adapter at 0x9000.
i82557 chip registers at 0x9000:
   0c000050 03b52000 00000000 00080002 1825c5e1 00000600
   No interrupt sources are pending.
    The transmit unit state is 'Suspended'.
    The receive unit state is 'Ready'.
   This status is normal for an activated but idle interface.
  The Command register has an unprocessed command 0c00(?!).
EEPROM contents, size 64x16:
     00: 3000 03f7 4ac5 0100 0000 0301 0701 0701
   0x08: 0000 0000 4840 0610 140b 0000 0000 0000
       ...
   0x38: 0000 0000 0000 0000 0000 0000 0000 c7a0
  The EEPROM checksum is correct.
Intel EtherExpress Pro 10/100 EEPROM contents:
   Station address 00:30:F7:03:C5:4A.
   Receiver lock-up bug exists. (The driver work-around *is* implemented.)
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555, PHY 1.
  MII PHY #1 transceiver registers:
   1000 782d 02a8 0154 05e1 c5e1 0009 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0203 0000 0001 082e 0000 0001 0ef1 0001
   0000 0000 0000 0000 0010 0000 0000 0000.
  Alternate MII PHY (#1) transceiver registers:
   1000 782d 02a8 0154 05e1 c5e1 0009 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0a03 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
   Baseline value of MII status register is 782d.

Index #2: Found a Intel 82559ER EtherExpressPro/100+ adapter at 0x9400.
i82557 chip registers at 0x9400:
   0c000050 03b04000 00000000 00080002 1825c5e1 00000600
   No interrupt sources are pending.
    The transmit unit state is 'Suspended'.
    The receive unit state is 'Ready'.
   This status is normal for an activated but idle interface.
  The Command register has an unprocessed command 0c00(?!).
EEPROM contents, size 64x16:
     00: 3000 03f7 4bc5 0100 0000 0301 0701 0701
   0x08: 0000 0000 4840 0610 140b 0000 0000 0000
       ...
   0x38: 0000 0000 0000 0000 0000 0000 0000 c6a0
  The EEPROM checksum is correct.
Intel EtherExpress Pro 10/100 EEPROM contents:
   Station address 00:30:F7:03:C5:4B.
   Receiver lock-up bug exists. (The driver work-around *is* implemented.)
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555, PHY 1.
  MII PHY #1 transceiver registers:
   1000 782d 02a8 0154 05e1 c5e1 0009 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0203 0000 0001 10c7 0000 0001 2388 0001
   0000 0000 0000 0000 0010 0000 0000 0000.
  Alternate MII PHY (#1) transceiver registers:
   1000 782d 02a8 0154 05e1 c5e1 0009 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0a03 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
   Baseline value of MII status register is 782d.

Index #3: Found a Intel 82559ER EtherExpressPro/100+ adapter at 0x9800.
i82557 chip registers at 0x9800:
   0c000050 03aa9000 00000000 00080002 18250000 00000600
   No interrupt sources are pending.
    The transmit unit state is 'Suspended'.
    The receive unit state is 'Ready'.
   This status is normal for an activated but idle interface.
  The Command register has an unprocessed command 0c00(?!).
EEPROM contents, size 64x16:
     00: 3000 03f7 4cc5 0100 0000 0301 0701 0701
   0x08: 0000 0000 4840 0610 140b 0000 0000 0000
       ...
   0x38: 0000 0000 0000 0000 0000 0000 0000 c5a0
  The EEPROM checksum is correct.
Intel EtherExpress Pro 10/100 EEPROM contents:
   Station address 00:30:F7:03:C5:4C.
   Receiver lock-up bug exists. (The driver work-around *is* implemented.)
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555, PHY 1.
  MII PHY #1 transceiver registers:
   1000 7809 02a8 0154 05e1 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
  Alternate MII PHY (#1) transceiver registers:
   1000 7809 02a8 0154 05e1 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
   Baseline value of MII status register is 7809.

Index #4: Found a Intel 82559ER EtherExpressPro/100+ adapter at 0x9c00.
i82557 chip registers at 0x9c00:
   0c000050 03a84000 00000000 00080002 18250000 00000600
   No interrupt sources are pending.
    The transmit unit state is 'Suspended'.
    The receive unit state is 'Ready'.
   This status is normal for an activated but idle interface.
  The Command register has an unprocessed command 0c00(?!).
EEPROM contents, size 64x16:
     00: 3000 03f7 4dc5 0100 0000 0301 0701 0701
   0x08: 0000 0000 4840 0610 140b 0000 0000 0000
       ...
   0x38: 0000 0000 0000 0000 0000 0000 0000 c4a0
  The EEPROM checksum is correct.
Intel EtherExpress Pro 10/100 EEPROM contents:
   Station address 00:30:F7:03:C5:4D.
   Receiver lock-up bug exists. (The driver work-around *is* implemented.)
   Board assembly 000000-000, Physical connectors present: RJ45
   Primary interface chip i82555 PHY #1.
     Secondary interface chip i82555, PHY 1.
  MII PHY #1 transceiver registers:
   1000 7809 02a8 0154 05e1 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
  Alternate MII PHY (#1) transceiver registers:
   1000 7809 02a8 0154 05e1 0000 0000 0000
   0000 0000 0000 0000 0000 0000 0000 0000
   0000 0000 0001 0000 0000 0000 0000 0000
   0000 0000 0000 0000 0010 0000 0000 0000.
   Baseline value of MII status register is 7809.


-- 
Ben Greear <greearb@candelatech.com>       <Ben_Greear AT excite.com>
President of Candela Technologies Inc      http://www.candelatech.com
ScryMUD:  http://scry.wanfear.com     http://scry.wanfear.com/~greear
