From: Andreas Jellinghaus <aj@dungeon.inka.de>
Subject: ipsec 2.5.70 trouble
Date: 29 May 2003 21:05:55 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <1054235155.596.9.camel@simulacron>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I create a single ping, I can see the packet plain in OUTPUT iptable,
I can see the packet encrypted with tcpdump on the source machine.

but on the target machine (same lan), I see the
packets encrypted, but where is that second packet in tcpdump
comming from?

ping 192.168.1.1

source machine has real ip eth0 192.168.0.10 and for ipsec an additional
192.168.3.2, and a default route with src 192.168.3.2 and an ipsec
policy put everything from/to 192.168.3.2 in a tunnel
192.168.0.10-192.168.0.1.

source machine iptables
May 29 20:36:26 simulacron kernel: iptlog.output IN= OUT=eth0
SRC=192.168.3.2 DST=192.168.1.1 LEN=84 TOS=0x00 PREC=0x00 TTL=64 ID=0 DF
PROTO=ICMP TYPE=8 CODE=0 ID=32002 SEQ=1 

source machine tcpdump
20:36:26.296466 192.168.0.10 > 192.168.0.1: ESP(spi=0x0dfc33a3,seq=0x7)
(DF)

destination machine tcpdump
tcpdump: listening on eth0
20:35:23.773924 192.168.0.10 > 192.168.0.1: ESP(spi=0x0dfc33a3,seq=0x7)
(DF)
20:35:23.773924 truncated-ip - 24 bytes missing!192.168.0.10 >
192.168.0.1: truncated-ip - 13087 bytes missing!64.4.224.214 >
192.168.0.10: (frag 17664:13167@672) [tos 0xfc]  (ipip)

destination machine iptables
May 29 20:35:23 localhost kernel: iptlog.input IN=eth0 OUT=
MAC=00:e0:7d:01:bb:0d:00:04:76:45:01:6e:08:00 SRC=192.168.0.10
DST=192.168.0.1 LEN=152 TOS=0x00 PREC=0x00 TTL=64 ID=55297 DF PROTO=ESP
SPI=0xdfc33a3 

Regards, Andreas
