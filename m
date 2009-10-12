From: Denys Fedoryschenko <denys@visp.net.lb>
Subject: kernel mode pppoe ppp if + ifb + mirred redirect, ethernet packets in ifb?!
Date: Mon, 12 Oct 2009 11:43:39 +0300
Message-ID: <200910121143.39924.denys@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:36237 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754672AbZJLIpi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Oct 2009 04:45:38 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

I am using kernel mode pppoe, and while using mirred on ppp interfaces (to 
shape users upstream) noticed very strange behaviour (and IMHO wrong)

$2 - ppp interface
tc filter add dev $2 parent ffff: protocol ip prio 10 u32 \
match u32 0 0 flowid 1:1 \
action mirred egress redirect dev ifb0"

If i do tcpdump on ppp interface i can see normal ip traffic

PPPoE_146 ~ # tcpdump -ni ppp6 -c 100
tcpdump: WARNING:
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ppp6, link-type LINUX_SLL (Linux cooked), capture size 96 bytes
11:36:16.541742 IP 172.16.131.221.2182 > 64.4.50.51.443: Flags [F.], seq 
2636760792, ack 2812561777, win 64963, length 0

If i do tcpdump on ifb0 i will see PPPoE incapsulated traffic! 
PPPoE_146 ~ # tcpdump -ni ifb0 -c 100
tcpdump: WARNING: ifb0: no IPv4 address assigned
tcpdump: verbose output suppressed, use -v or -vv for full protocol decode
listening on ifb0, link-type EN10MB (Ethernet), capture size 96 bytes
11:36:58.949727 PPPoE  [ses 0x15] IP 172.16.98.22.2081 > 94.75.218.20.80: 
Flags [S], seq 3205622298, win 65535, options [mss 1440,nop,nop,sackOK], 
length 0
11:36:58.531473 PPPoE  [ses 0xd] IP 172.16.98.14.16526 > 128.16.130.164.445: 
Flags [S], seq 98566173, win 65535, options [mss 1440,nop,nop,sackOK], length 
0

Is it expected that redirecting ppp interface, that supposed to be clean IP 
traffic is becoming eth encapsulated traffic?
Probably some bad interaction with kernel mode pppoe?
