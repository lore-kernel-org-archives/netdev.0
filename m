From: Michal Ludvig <michal@logix.cz>
Subject: IPsec SPI/SEQ badness on forward
Date: Fri, 01 Apr 2005 15:14:50 +1200
Message-ID: <424CBCAA.8030503@logix.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-2
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: ipsec-tools-devel@lists.sourceforge.net, netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi all,

I'm running the most recent 2.6.12-rc1-bk with ipsec-tools 0.5.1,
setting up tunnel mode between networks 192.168.0.0/24 (gateway K.L.M.N)
and 192.168.157.0/24 (gw A.B.C.D/192.168.157.1).

When pinging from the gateway 192.168.157.1 (i.e. locally generated
packets) the ESP packets have correct SPI/SEQ number:
13:47:14.334879 A.B.C.D > K.L.M.N: ESP(spi=0xebfb16c9,seq=0x1) (DF)
               13:47:25.988419 A.B.C.D > K.L.M.N:
ESP(spi=0xebfb16c9,seq=0x2) (DF)
13:47:49.190173 A.B.C.D > K.L.M.N: ESP(spi=0xebfb16c9,seq=0x3) (DF)


However when pinging from the host in the internal net (e.g.
192.168.157.21, i.e. forwarded packets) the lower half of SPI is wrong
as is the upper half of SEQ:
13:48:28.373633 A.B.C.D > K.L.M.N: ESP(spi=0xebfbd458,seq=0x42700004) (DF)
13:49:13.934759 A.B.C.D > K.L.M.N: ESP(spi=0xebfbd358,seq=0x43700005) (DF)
13:49:19.929667 A.B.C.D > K.L.M.N: ESP(spi=0xebfbd258,seq=0x44700006) (DF)

Note that the lower half of SEQ grows as expected...

Now pinging from the gateway again and it works again:
13:49:27.529796 A.B.C.D > K.L.M.N: ESP(spi=0xebfb16c9,seq=0x7) (DF)

Have anyone else seen a similar behaviour? Any ideas what is wrong?
Looks like the kernel isn't clearing some buffers when forwarding
packets to IPSec tunnel...

Michal Ludvig
