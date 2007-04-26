From: "Ristuccia, Brian" <bristuccia@starentnetworks.com>
Subject: RE: 2.6.20.7 mss negotiation and path mtu discovery mostly broken?
Date: Thu, 26 Apr 2007 11:53:04 -0400
Message-ID: <7CCD07160348804497EF29E9EA5560D7020F621C@exchtewks2.starentnetworks.com>
References: <E1HgqHf-0003xF-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.starentnetworks.com ([12.38.223.203]:41237 "EHLO
	mx0.starentnetworks.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1031291AbXDZPxM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Apr 2007 11:53:12 -0400
Content-Class: urn:content-classes:message
In-Reply-To: <E1HgqHf-0003xF-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> > 
> > 08:39:55.649689 IP 10.2.10.254.22 > 12.33.234.69.35026: .
> > 5906:10250(4344) ack 1
> > 794 win 674 <nop,nop,timestamp 413790 3873837887>
> > 08:39:55.650532 IP 10.2.10.1 > 10.2.10.254: icmp 92: 12.33.234.69 
> > unreachable - need to frag (mtu 1500)
> 
> Where was this dump taken, on 10.2.10.254?
> 

Yes. It appears that if tcpdump is run on the sending system it sees the
packets before segmentation offload does its thing. 

> If so could youd either take the dump further down the route 
> or show the full contents (with tcpdump -x) of the ICMP error 
> here so that we can see what the actual packet size was?
> 

Here's an example IP packet followed by the resulting ICMP as seen with
tcpdump on  10.2.10.254. ICMP is complaining about a 2896 byte packet,
which leads me to believe that the TSO is using the wrong mss or simply
isn't doing anything at all. 

11:36:12.006330 IP (tos 0x8, ttl  64, id 20681, offset 0, flags [DF],
length: 29
48) 10.2.10.254.22 > 12.33.234.69.47703: . 91224:94120(2896) ack 49 win
674 <nop
,nop,timestamp 24659048 3970819017>
        0x0000:  4508 0b84 50c9 4000 4006 d33c 0a02 0afe
E...P.@.@..<....
        0x0010:  0c21 ea45 0016 ba57 09f8 1838 7577 90cb
.!.E...W...8uw..
        0x0020:  8010 02a2 16dd 0000 0101 080a 0178 4468
.............xDh
        0x0030:  ecad e3c9 96f8 ad0d e909 4e89 202a 9d85
..........N..*..
        0x0040:  4b58 a65f 53d9 07f4 0435 2557 970b 943d
KX._S....5%W...=
        0x0050:  1eba                                     ..
11:36:12.007019 IP (tos 0x0, ttl  64, id 43865, offset 0, flags [DF],
length: 11
2) 10.2.10.1 > 10.2.10.254: icmp 92: 12.33.234.69 unreachable - need to
frag (mt
u 1500) for IP (tos 0x8, ttl  64, id 20681, offset 0, flags [DF],
length: 2948)
10.2.10.254.22 > 12.33.234.69.47703: . 91224:94120(2896) ack 49 win 674
<nop,nop
,timestamp 24659048 3970819017>
        0x0000:  4500 0070 ab59 4000 4001 6631 0a02 0a01
E..p.Y@.@.f1....
        0x0010:  0a02 0afe 0304 7cc8 0000 05dc 4508 0b84
......|.....E...
        0x0020:  50c9 4000 4006 d33c 0a02 0afe 0c21 ea45
P.@.@..<.....!.E
        0x0030:  0016 ba57 09f8 1838 7577 90cb 8010 02a2
...W...8uw......
        0x0040:  706d 0000 0101 080a 0178 4468 ecad e3c9
pm.......xDh....
        0x0050:  96f8             

-Brian


"This email message and any attachments are confidential information of Starent Networks, Corp. The information transmitted may not be used to create or change any contractual obligations of Starent Networks, Corp.  Any review, retransmission, dissemination or other use of, or taking of any action in reliance upon this e-mail and its attachments by persons or entities other than the intended recipient is prohibited. If you are not the intended recipient, please notify the sender immediately -- by replying to this message or by sending an email to postmaster@starentnetworks.com -- and destroy all copies of this message and any attachments without reading or disclosing their contents. Thank you."
