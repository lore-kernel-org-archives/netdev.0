From: David Greaves <david@dgreaves.com>
Subject: 2.6.6 e1000 NETDEV WATCHDOG: eth0: transmit timed out
Date: Mon, 14 Jun 2004 17:47:08 +0100
Sender: netdev-bounce@oss.sgi.com
Message-ID: <40CDD68C.8070509@dgreaves.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: shemminger@osdl.org, scott.feldman@intel.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi

I have 2 machines with Intel/Pro 1000MT cards.

One machine seems to work fine (AFAIK), the other has major problems.
I've swapped the cards and the problem stays on the machine.

I'm using version 5.2.39-k2 from the stock 2.6.6 kernel on both machines.

Any sustained traffic causes repeated:
Jun 14 16:29:14 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out
Jun 14 16:29:17 ash kernel: e1000: eth0 NIC Link is Up 1000 Mbps Full Duplex
Jun 14 16:29:17 ash kernel: nfs: server cu OK

I had a pair of Realtek r8169s that worked fine but only gave me 10Mb/s 
so I exchanged them for the Intel/Pro cards in the hope of something 
better - now, even with scp's rate limiter as low as 10kb/s this it 
still occurs.

I have played with all the module parameters and not found anything that 
affects it at 1Gbps

Even dropping to 100Mbps:
Jun 14 17:33:03 ash kernel: e1000: eth0 NIC Link is Up 100 Mbps Full Duplex
Jun 14 17:33:33 ash kernel: NETDEV WATCHDOG: eth0: transmit timed out

it can do 10Mbs:
scp reports a throughput of 1.0Mb/s (... less than thrilling)
however scp now transfers a few Mb and says:
Disconnecting: Corrupted MAC on input.



I found this mail:
  http://oss.sgi.com/projects/netdev/archive/2004-06/msg00256.html
from Stephen

which appears to reverse this mail:
  http://marc.theaimsgroup.com/?l=linux-kernel&m=107516205706542&w=2
from Scott
which I gather was supposed to correct this problem :)

I have seen no suggestions about other subsystems (eg ACPI etc) that 
could also be tried.

David
