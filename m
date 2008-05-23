From: James Chapman <jchapman@katalix.com>
Subject: Re: Wired behaviour with IPv6 over PPP
Date: Fri, 23 May 2008 22:34:04 +0100
Message-ID: <4837384C.8050100@katalix.com>
References: <48341C0B.7010003@interway.ch> <20080522014959.0f6191aa.akpm@linux-foundation.org> <48354318.60202@katalix.com> <4835C40B.60603@interway.ch> <4836A06C.2050301@katalix.com> <48372017.7080008@interway.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Matthias Cramer <matthias.cramer@interway.ch>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s36.avahost.net ([74.53.95.194]:53573 "EHLO s36.avahost.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756840AbYEWVeW (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 23 May 2008 17:34:22 -0400
In-Reply-To: <48372017.7080008@interway.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Matthias Cramer wrote:
> Hi James
> 
> James Chapman wrote:
>> Matthias Cramer wrote:
>>> James Chapman wrote:
>>>> Did this work with previous kernel versions?
>>> No, in my opinion it never worked. But I thought that pppd does it wrong
>>> because id never got an IPv6 address. But I had always forwarding
>>> enabled. Now in this case i started pppd without forwarding enabled and
>>> got an address.
>>>
>>>> Does pppd log any errors?
>>> No, no errors
>> Could you post a pppd debug log showing the ppp protocol exchange with
>> the peer in the failing case? It might give some clues.
> 
> Here the logs ... First with forwarding enabled and second with disabled ...

Thanks. The 2 logs show the same PPP packets are exchanged in each case. 
The only difference that I spotted is the order in which the ip-up and 
ip6-up scripts are called. In the working case, ip6-up starts and 
finishes before ip-up starts. In the failing case, ip-up starts before 
ip6-up finishes. What do these scripts do? What might happen if they 
both run at the same time?

> net.ipv6.conf.all.forwarding=1
> 
> May 23 21:38:49 alix-tst pppd[29490]: Plugin rp-pppoe.so loaded.
> May 23 21:38:49 alix-tst pppd[29491]: pppd 2.4.4 started by root, uid 0
> May 23 21:38:49 alix-tst pppd[29491]: PADS: Service-Name: ''
> May 23 21:38:49 alix-tst pppd[29491]: PPP session is 675
> May 23 21:38:49 alix-tst pppd[29491]: using channel 10
> May 23 21:38:49 alix-tst pppd[29491]: Using interface ppp0
> May 23 21:38:49 alix-tst pppd[29491]: Connect: ppp0 <--> eth0
> May 23 21:38:49 alix-tst pppd[29491]: sent [LCP ConfReq id=0x1 <mru 1492> <magic 0xadacf61b>]
> May 23 21:38:49 alix-tst pppd[29491]: rcvd [LCP ConfReq id=0xc8 <mru 1492> <auth chap MD5> <magic 0x6887033f>]
> May 23 21:38:49 alix-tst pppd[29491]: sent [LCP ConfAck id=0xc8 <mru 1492> <auth chap MD5> <magic 0x6887033f>]
> May 23 21:38:49 alix-tst pppd[29491]: rcvd [LCP ConfAck id=0x1 <mru 1492> <magic 0xadacf61b>]
> May 23 21:38:49 alix-tst pppd[29491]: sent [LCP EchoReq id=0x0 magic=0xadacf61b]
> May 23 21:38:49 alix-tst pppd[29491]: rcvd [CHAP Challenge id=0xa7 <c3ca04555d0b05c824913a485207145a>, name = "ipc-zhh790-r-br-03"]
> May 23 21:38:49 alix-tst pppd[29491]: sent [CHAP Response id=0xa7 <4e5f2e265676afd4426f96a4f3d69d98>, name = "dol/test@bestadsl.ch"]
> May 23 21:38:49 alix-tst pppd[29491]: rcvd [LCP EchoRep id=0x0 magic=0x6887033f]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [LCP ConfReq id=0x1 <auth pap> <magic 0x81e3711d>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP ConfReq id=0x2 <mru 1492> <magic 0xe78877a6>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP ConfAck id=0x1 <auth pap> <magic 0x81e3711d>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [LCP ConfAck id=0x2 <mru 1492> <magic 0xe78877a6>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP EchoReq id=0x0 magic=0xe78877a6]
> May 23 21:38:50 alix-tst pppd[29491]: sent [PAP AuthReq id=0x1 user="dol/test@bestadsl.ch" password=<hidden>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [LCP ConfReq id=0x1 <mru 1492> <auth chap MD5> <magic 0x708ab66f>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP ConfReq id=0x3 <mru 1492> <magic 0xade5da06>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP ConfAck id=0x1 <mru 1492> <auth chap MD5> <magic 0x708ab66f>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [LCP ConfAck id=0x3 <mru 1492> <magic 0xade5da06>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [LCP EchoReq id=0x0 magic=0xade5da06]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [CHAP Challenge id=0x1 <5de7704ca9b8440a185c21438e465653>, name = "brain.glb"]
> May 23 21:38:50 alix-tst pppd[29491]: sent [CHAP Response id=0x1 <7cca580881d4ca01c3f191382ec97df2>, name = "dol/test@bestadsl.ch"]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [LCP EchoRep id=0x0 magic=0x708ab66f]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [CHAP Success id=0x1 ""]
> May 23 21:38:50 alix-tst pppd[29491]: CHAP authentication succeeded
> May 23 21:38:50 alix-tst pppd[29491]: CHAP authentication succeeded
> May 23 21:38:50 alix-tst pppd[29491]: peer from calling number 00:90:1A:A0:3D:B9 authorized
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPCP ConfReq id=0x1 <addr 0.0.0.0> <ms-dns1 0.0.0.0> <ms-dns3 0.0.0.0>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPV6CP ConfReq id=0x1 <addr fe80::e0d4:2d3f:e674:e204>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPCP ConfReq id=0x1 <compress VJ 0f 01> <addr 212.25.27.37>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPCP ConfRej id=0x1 <compress VJ 0f 01>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPV6CP ConfReq id=0x1 <addr fe80::0219:56ff:fe99:49e0>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPV6CP ConfAck id=0x1 <addr fe80::0219:56ff:fe99:49e0>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPCP ConfNak id=0x1 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPCP ConfReq id=0x2 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPV6CP ConfAck id=0x1 <addr fe80::e0d4:2d3f:e674:e204>]
> May 23 21:38:50 alix-tst pppd[29491]: local  LL address fe80::e0d4:2d3f:e674:e204
> May 23 21:38:50 alix-tst pppd[29491]: remote LL address fe80::0219:56ff:fe99:49e0
> May 23 21:38:50 alix-tst pppd[29491]: Script /etc/ppp/ipv6-up started (pid 29513)
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPCP ConfReq id=0x2 <addr 212.25.27.37>]
> May 23 21:38:50 alix-tst pppd[29491]: sent [IPCP ConfAck id=0x2 <addr 212.25.27.37>]
> May 23 21:38:50 alix-tst pppd[29491]: rcvd [IPCP ConfAck id=0x2 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:38:50 alix-tst pppd[29491]: Cannot determine ethernet address for proxy ARP
> May 23 21:38:50 alix-tst pppd[29491]: local  IP address 212.25.16.1
> May 23 21:38:50 alix-tst pppd[29491]: remote IP address 212.25.27.37
> May 23 21:38:50 alix-tst pppd[29491]: primary   DNS address 212.25.28.55
> May 23 21:38:50 alix-tst pppd[29491]: secondary DNS address 194.246.118.118
> May 23 21:38:50 alix-tst pppd[29491]: Script /etc/ppp/ip-up started (pid 29516)
> May 23 21:38:50 alix-tst pppd[29491]: Script /etc/ppp/ipv6-up finished (pid 29513), status = 0x0
> May 23 21:38:50 alix-tst postfix/master[4248]: reload configuration /etc/postfix
> May 23 21:38:50 alix-tst pppd[29491]: Script /etc/ppp/ip-up finished (pid 29516), status = 0x0
> 
> ppp0      Link encap:Point-to-Point Protocol
>           inet addr:212.25.16.1  P-t-P:212.25.27.37  Mask:255.255.255.255
>           inet6 addr: fe80::e0d4:2d3f:e674:e204/10 Scope:Link
>           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1492  Metric:1
>           RX packets:12 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:6 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:3
>           RX bytes:562 (562.0 B)  TX bytes:92 (92.0 B)
> 
> 
> 
> net.ipv6.conf.all.forwarding=0
> 
> May 23 21:43:35 alix-tst pppd[32142]: Plugin rp-pppoe.so loaded.
> May 23 21:43:35 alix-tst pppd[32143]: pppd 2.4.4 started by root, uid 0
> May 23 21:43:36 alix-tst pppd[32143]: PADS: Service-Name: ''
> May 23 21:43:36 alix-tst pppd[32143]: PPP session is 757
> May 23 21:43:36 alix-tst pppd[32143]: using channel 11
> May 23 21:43:36 alix-tst pppd[32143]: Using interface ppp0
> May 23 21:43:36 alix-tst pppd[32143]: Connect: ppp0 <--> eth0
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfReq id=0x1 <mru 1492> <magic 0x7e7c4da8>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfReq id=0xad <mru 1492> <auth chap MD5> <magic 0x7598a7>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfAck id=0xad <mru 1492> <auth chap MD5> <magic 0x7598a7>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfAck id=0x1 <mru 1492> <magic 0x7e7c4da8>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP EchoReq id=0x0 magic=0x7e7c4da8]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [CHAP Challenge id=0x31 <ae504fb324a1da70f0f2d580402ab1ac>, name = "ipc-zhh790-r-br-03"]
> May 23 21:43:36 alix-tst pppd[32143]: sent [CHAP Response id=0x31 <41629cee25511522e5d4b55e7f58c15a>, name = "dol/test@bestadsl.ch"]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP EchoRep id=0x0 magic=0x7598a7]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfReq id=0x1 <auth pap> <magic 0x59441d38>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfReq id=0x2 <mru 1492> <magic 0x14756caf>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfAck id=0x1 <auth pap> <magic 0x59441d38>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfAck id=0x2 <mru 1492> <magic 0x14756caf>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP EchoReq id=0x0 magic=0x14756caf]
> May 23 21:43:36 alix-tst pppd[32143]: sent [PAP AuthReq id=0x1 user="dol/test@bestadsl.ch" password=<hidden>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfReq id=0x1 <mru 1492> <auth chap MD5> <magic 0x708f14c5>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfReq id=0x3 <mru 1492> <magic 0x653c44db>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP ConfAck id=0x1 <mru 1492> <auth chap MD5> <magic 0x708f14c5>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP ConfAck id=0x3 <mru 1492> <magic 0x653c44db>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [LCP EchoReq id=0x0 magic=0x653c44db]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [CHAP Challenge id=0x1 <4df4d05ddfc7b9e3185c2143e82a0bab>, name = "brain.glb"]
> May 23 21:43:36 alix-tst pppd[32143]: sent [CHAP Response id=0x1 <7833c4a255c53c29b4256e6c129b8718>, name = "dol/test@bestadsl.ch"]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [LCP EchoRep id=0x0 magic=0x708f14c5]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [CHAP Success id=0x1 ""]
> May 23 21:43:36 alix-tst pppd[32143]: CHAP authentication succeeded
> May 23 21:43:36 alix-tst pppd[32143]: CHAP authentication succeeded
> May 23 21:43:36 alix-tst pppd[32143]: peer from calling number 00:90:1A:A0:3D:B9 authorized
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPCP ConfReq id=0x1 <addr 0.0.0.0> <ms-dns1 0.0.0.0> <ms-dns3 0.0.0.0>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPV6CP ConfReq id=0x1 <addr fe80::91af:5025:4398:606b>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPCP ConfReq id=0x1 <compress VJ 0f 01> <addr 212.25.27.37>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPCP ConfRej id=0x1 <compress VJ 0f 01>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPV6CP ConfReq id=0x1 <addr fe80::0219:56ff:fe99:49e0>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPV6CP ConfAck id=0x1 <addr fe80::0219:56ff:fe99:49e0>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPCP ConfNak id=0x1 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPCP ConfReq id=0x2 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPV6CP ConfAck id=0x1 <addr fe80::91af:5025:4398:606b>]
> May 23 21:43:36 alix-tst pppd[32143]: local  LL address fe80::91af:5025:4398:606b
> May 23 21:43:36 alix-tst pppd[32143]: remote LL address fe80::0219:56ff:fe99:49e0
> May 23 21:43:36 alix-tst pppd[32143]: Script /etc/ppp/ipv6-up started (pid 32150)
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPCP ConfReq id=0x2 <addr 212.25.27.37>]
> May 23 21:43:36 alix-tst pppd[32143]: sent [IPCP ConfAck id=0x2 <addr 212.25.27.37>]
> May 23 21:43:36 alix-tst pppd[32143]: Script /etc/ppp/ipv6-up finished (pid 32150), status = 0x0
> May 23 21:43:36 alix-tst pppd[32143]: rcvd [IPCP ConfAck id=0x2 <addr 212.25.16.1> <ms-dns1 212.25.28.55> <ms-dns3 194.246.118.118>]
> May 23 21:43:36 alix-tst pppd[32143]: Cannot determine ethernet address for proxy ARP
> May 23 21:43:36 alix-tst pppd[32143]: local  IP address 212.25.16.1
> May 23 21:43:36 alix-tst pppd[32143]: remote IP address 212.25.27.37
> May 23 21:43:36 alix-tst pppd[32143]: primary   DNS address 212.25.28.55
> May 23 21:43:36 alix-tst pppd[32143]: secondary DNS address 194.246.118.118
> May 23 21:43:36 alix-tst pppd[32143]: Script /etc/ppp/ip-up started (pid 32153)
> May 23 21:43:37 alix-tst pppd[32143]: Script /etc/ppp/ip-up finished (pid 32153), status = 0x0
> 
> 
> ppp0      Link encap:Point-to-Point Protocol
>           inet addr:212.25.16.1  P-t-P:212.25.27.37  Mask:255.255.255.255
>           inet6 addr: 2001:8e0:1000:b:91af:5025:4398:606b/64 Scope:Global
>           inet6 addr: fe80::91af:5025:4398:606b/10 Scope:Link
>           UP POINTOPOINT RUNNING NOARP MULTICAST  MTU:1492  Metric:1
>           RX packets:20 errors:0 dropped:0 overruns:0 frame:0
>           TX packets:18 errors:0 dropped:0 overruns:0 carrier:0
>           collisions:0 txqueuelen:3
>           RX bytes:1290 (1.2 KiB)  TX bytes:1276 (1.2 KiB)
> 
> 

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

