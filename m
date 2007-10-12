From: Chuck Anderson <cra@WPI.EDU>
Subject: "ping6 -M do" fragments packets
Date: Fri, 12 Oct 2007 11:18:41 -0400
Message-ID: <20071012151841.GE3789@angus.ind.WPI.EDU>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from MAIL1.WPI.EDU ([130.215.36.91]:47898 "EHLO mail1.wpi.edu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754497AbXJLPyc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 12 Oct 2007 11:54:32 -0400
Received: from mcafee.wpi.edu (MCAFEE.WPI.EDU [130.215.36.86])
	by mail1.wpi.edu (8.14.1/8.14.1) with SMTP id l9CFIgwA009471
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 11:18:42 -0400
Received: from angus.ind.WPI.EDU (ANGUS.IND.WPI.EDU [130.215.130.21])
	by SMTP.WPI.EDU (8.13.8/8.13.8) with ESMTP id l9CFIg1n013075
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 11:18:42 -0400
	(envelope-from cra@WPI.EDU)
Received: from angus.ind.WPI.EDU (angus.ind.WPI.EDU [127.0.0.1])
	by angus.ind.WPI.EDU (8.14.1/8.13.8) with ESMTP id l9CFIgXU025014
	for <netdev@vger.kernel.org>; Fri, 12 Oct 2007 11:18:42 -0400
Received: (from cra@localhost)
	by angus.ind.WPI.EDU (8.14.1/8.14.1/Submit) id l9CFIfRk025013
	for netdev@vger.kernel.org; Fri, 12 Oct 2007 11:18:41 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I'm not subscribed, so please Cc: me on any responses.  Thanks.

According to the man page, ping6 should support the "-M do" option so 
never fragment packets, which I'd like to use for testing the MTU of a 
path.  This option works fine for IPv4 ping, but doesn't work with 
IPv6 ping6.  I can guarantee that I don't have an MTU of 63356 :-)

>ping6 -M do -s 65527 www.kame.net
PING www.kame.net(orange.kame.net) 65527 data bytes
65535 bytes from orange.kame.net: icmp_seq=1 ttl=49 time=224 ms
65535 bytes from orange.kame.net: icmp_seq=2 ttl=49 time=226 ms
65535 bytes from orange.kame.net: icmp_seq=3 ttl=49 time=224 ms

--- www.kame.net ping statistics ---
3 packets transmitted, 3 received, 0% packet loss, time 1999ms
rtt min/avg/max/mdev = 224.118/225.270/226.909/1.251 ms

Sure enough, wireshark reports fragments:

No.     Time        Source                Destination           Protocol Info
      1 0.000000    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=0 id=0x79)
      2 0.000007    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=1448 id=0x79)
      3 0.000010    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=2896 id=0x79)
      4 0.000013    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=4344 id=0x79)
      5 0.000015    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=5792 id=0x79)
      6 0.000018    2001:468:616:8c9:213:72ff:fe74:da15 2001:200:0:8002:203:47ff:fea5:3085 IPv6     IPv6 fragment (nxt=ICMPv6 (0x3a) off=7240 id=0x79)


Is this a known issue, or some issue with the Fedora build I'm using?

iputils-20070202-3.fc7

Thanks.
