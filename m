From: Yuehai Xu <yuehaixu@gmail.com>
Subject: How do I know my driver support RSS?
Date: Sat, 3 Mar 2012 16:25:58 -0500
Message-ID: <CAEc1PS1j2DL4m7B1Rp9nseqLWsxaXXY+ZJDHra+99c5-WPgYcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: linux-kernel@vger.kernel.org,
	Eric Dumazet <eric.dumazet@gmail.com>, yhxu@wayne.edu,
	sbw@mit.edu
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

The Linux version is 3.1.4,

ethtool -i eth0:
driver: bnx2
version: 2.1.11
firmware-version: 5.2.7 bc 5.2.2 NCSI 2.0.8
bus-info: 0000:01:00.0

cat /proc/interrupts | grep eth0:
  75:   21055507          0          0          0          0
0          0          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-0
  76:      13525   16727512          0          0          0
0          0          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-1
  77:      11057          0   15796802          0          0
0          0          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-2
  78:     186481          0          0   31960030          0
0          0          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-3
  79:     122343          0          0          0   32711648
0          0          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-4
  80:     391642          0          0          0          0
164243994          0          0          0          0          0
   0          0          0          0          0          0          0
         0          0          0          0          0          0
PCI-MSI-edge      eth0-5
  81:     681084          0          0          0          0
0   41645128          0          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-6
  82:      39207          0          0          0          0
0          0   30973807          0          0          0          0
      0          0          0          0          0          0
 0          0          0          0          0          0
PCI-MSI-edge      eth0-7

>From /proc/interrupts I know that my network card has 8 rx/tx queues.
However, after reading
http://code.google.com/p/kernel/wiki/NetScalingGuide#RSS:_Receive_Side_Scaling,
I still have no idea whether I have enabled RSS for my network card.

Since I read the following statements from a paper, "we use a separate
hardware receive and transmit queue for each core and configure the
IXGBE to inspect the port number in each incoming packet header, place
the packet on the queue dedicated to the associated memcached's core,
and deliver the receive interrupt to that core." and the background of
this configuration is that each memcached is pinned to a separate core
and has its own UDP port. It seems that IXGBE's driver can detect UDP
packets according to their port numbers and put these packets into
corresponding receive queues in the hardware, is this achieved by
configuring RSS in IXGBE? If it is, I am wondering whether bnx2
supports RSS and whether it can configure in the same way.

I appreciate any help for this.

Thanks,
Yuehai
