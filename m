From: Joy Latten <latten@austin.ibm.com>
Subject: IPSecv6 tunnel mode beahviour
Date: Mon, 1 Nov 2004 19:14:50 +0000 (UTC)
Message-ID: <200411030433.iA34Xnou017836@faith.austin.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
Date: Tue, 2 Nov 2004 22:33:49 -0600
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am using 2.6.9 + 2.6.10-rc1 + 2.6.10-rc1-bk5 kernel.
I also recall seeing this before 2.6.9...

I am running IPSecv6 in tunnelmode and am noticing what
I think is odd behaviour.
 
First, I have a simple config where packets go from one subnet
to another through my ipsec tunnel.

I noticed TCPv6 packets are being fragmented at the tunnel.
I did not see this using similar configuration with ipv4.
Although the packets are received ok, sniffer output looks odd
to me, it appears Fragment header was not removed at tunnel 
endpoint because I still see it after packet was forwarded on 
subnet to receiving machine. Sniffer on receiving machine's
interface shows...

	Frame 15...
	Ethernet II...
	Internet Protocol Version 6
	Fragmentation Header
		Next Header TCP
		Offset: 0
		More fragments: No
		Identification: 0x00000000
	Transmission Protocol..


I see odd behaviour in ICMPv6 too if I send packet larger than
mtu of sender. Packet is fragmented twice, once at sender and
then again at tunnel entry point. My ping works fine, but, what 
is odd, is that again Fragment Header is not removed, such that 
after packet is forwarded onto receiving subnet and reaches 
receiving machine, there are 2 fragment headers. 
sniffer output on receiver...
	Frame 1...
	Ethernet II...	
	Internet Protocol Version 6
	Fragment Header
		Next header: IPv6 fragment(0x2c)
		Offset: 0
		More fragments: No
		Identification: 0x00000000
	Fragment Header
		Next header: ICMPv6 (0x3a)
		Offset: 0
		More fragments: Yes
		Identification: 0x1300000
	Internet Control Message Protocol v6


What is the correct behaviour? Who should be removing Fragment
Header... tunnel endpoint... or should it even be there in TCPv6 case?

Joy Latten 
