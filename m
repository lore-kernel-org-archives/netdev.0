From: "Marco Berizzi" <pupilla@hotmail.com>
Subject: Re: wrong arp query with policy routing
Date: Wed, 19 Sep 2007 15:04:43 +0200
Message-ID: <BAY103-DAV12BF0DF9E47B1577FB9814B2B90@phx.gbl>
References: <BAY103-DAV2BC129A14C4A29986CC0CB2B80@phx.gbl>
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bay0-omc2-s23.bay0.hotmail.com ([65.54.246.159]:10512 "EHLO
	bay0-omc2-s23.bay0.hotmail.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753425AbXISNEz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 09:04:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marco Berizzi wrote:

> HDSL.225 dev eth0  scope link
> ADSL.129 dev eth0  scope link  src ADSL.134
> ADSL.128/29 dev eth1  proto kernel  scope link  src ADSL.134
> HDSL.224/27 dev eth1  proto kernel  scope link  src HDSL.254
> 127.0.0.0/8 dev lo  scope link
> default via HDSL.225 dev eth0  metric 1

> Chain OUTPUT (policy ACCEPT 2476380 packets, 1183993024 bytes)
>     pkts      bytes target     prot opt in     out     source
> destination
>    61064  8582064 MARK       tcp  --  *      *       0.0.0.0/0
> !172.16.0.0/12       multiport dports
> 20,21,80,123,443,2080,8080,8201,10000,8102,1443,81 MARK set 0x1

Me again.
When this box try to open a connection to
www.google.com:80 (for example), it send an
arp request like this:

15:12:38.246096 00:30:05:cb:27:c1 > ff:ff:ff:ff:ff:ff, ethertype ARP
(0x0806), length 42: arp who-has ADSL.129 tell HDSL.254
                                          ^^^^^^^^^^^^^
and the ISP managed cisco 877 router ignore
it, because the ip source address is from a
different network (should be ADSL.134 instead
of HDSL.254). Is this an expected behaviour
from linux?
Is there a way to force linux to make an arp
probe with the source ip belonging to the
same subnet requesting ip?

This is the 'ip ru sh' output:

0: from all lookup local
400: from all fwmark 0x1 lookup adsl
32766: from all lookup main
32767: from all lookup default

TIA


