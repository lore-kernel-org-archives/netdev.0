From: Ben Greear <greearb@candelatech.com>
Subject: 2.6.7 tulip performance (with NAPI)
Date: Tue, 05 Oct 2004 16:42:44 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <41633174.7070805@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

NOTE:  This test machine is running a P-IV 2.8Ghz processor, 32/33 PCI
bus, 512MB RAM, and kernels compiled for the P-IV processor.  I
am using a modified pktgen that can receive as well as transmit
packets, so I can get pkt-drop stats, etc.  User-space is FC2,
and X is running during these tests.


I just started doing some performance comparisons of
pktgen with a 4-port NIC (p430tx) that uses the tulip driver.  On 2.4.27
I can drive two ports at 95+Mbps, full duplex and the system is
very responsive.  If I try this on 2.6.7 (with tulip compiled to use
NAPI), I can still get the speed on the two ports, but the deskop
is very jittery.

If I try to start another pktgen test between the second two ports
on 2.4.27 I start seeing a reasonable number of packet drops, and the
bandwidth drops to about 55Mbps bi-directional.  The desktop is still
responsive.

If I try this on 2.6.7 the desktop jitter gets even worse.  The pktgen
tests start sending at about 7kpps (I'm using 1514 byte packets) but
I only receive about 1kpps.  My assumption is that the pktgen thread is
getting all the cpu and starving the NAPI receive thread.

I tried setting the NICE level of pktgen to -10 and softirq to -18.  I
still see way more packets transmitted than received.

I tried compiling the tulip driver to not use NAPI in 2.6.7.  This
achieved similar throughput (55Mbps on each NIC, full duplex) as the 2.4.27
kernel, and slowed down the pktgen transmitter so that fewer packets
were actually dropped.  The responsiveness is not good, but it is not
any worse than when using NAPI.

So, for my testing with send+receive traffic, it appears that tulip+NAPI
is actually not a good option.

If anyone has other performance comparisons with tulip on modern kernels,
please share!

Thanks,
Ben

-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
