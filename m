From: latten@austin.ibm.com
Subject: IPSecv6 AH doesn't work with Fragmenting
Date: Wed, 2 Jul 2003 18:54:23 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200307022354.h62NsMYP002987@faith.austin.ibm.com>
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

I am using netperf to stress IPSecv6 with AH protocol. Netperf sent
a stream of TCP packets to the receiver. I examined the log on
my receiver and saw many "IPSec ah authentication error" messages.
I then sniffed my incoming packets and saw that they had been
fragmented and each fragment was reported as being malformed.

   Source		Destination	Protocol	Info
1  fec0:0:0:105::56  	fec0:0:0:105::55  TCP		32780 > 32772 [ACK]...
2  fec0:0:0:105::56	fec0:0:0:105::55  AH		AH (SPI=0x00000000)[Malformed Packet]
3  fec0:0:0:105::55	fec0:0:0:105::56  TCP		32772 > 32780 [ACK]...
4  fec0:0:0:105::56	fec0:0:0:105::55  TCP		32780 > 32772 [ACK]...
5  fec0:0:0:105::56	fec0:0:0:105::55  AH		AH (SPI=0x00000000)[ Malformed Packet]

Just for the heck of it, I did a "ping6 -s 1800" and sniffed the wire and 
although the ping/ICMPv6 works fine in that I get a reply and no 
authentication failures are logged, my packets are reported as being 
malformed. 

It seems AH with fragmenting is not working properly and
perhaps that is the cause of all the AH authentication errors
I see in my log.

Unfortunately I could not cut and paste my ethereal output
but if anyone is interested I could send it. It is also 
easy to reproduce. Just configure AHv6  manually between two machines
and run netperf or ping6 -s or anything that would result in 
fragmentation.

Joy
