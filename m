From: "Denys" <denys@visp.net.lb>
Subject: HFSC dangerous behaviour (not a bug)
Date: Mon, 29 Oct 2007 02:02:39 +0200
Message-ID: <20071028235224.M3269@visp.net.lb>
Mime-Version: 1.0
Content-Type: text/plain;
	charset=koi8-r
Cc: kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from usermail.globalproof.net ([194.146.153.18]:33653 "EHLO
	usermail.globalproof.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752709AbXJ2ACu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Oct 2007 20:02:50 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi All

During testing i found very strange thing. 
After applying even example shaper:
http://linux-ip.net/tc/hfsc.en/
-------------
#  Example  from  Figure  1. 
tc  qdisc  add  dev  eth0  root  handle  1:  hfsc 
tc  class  add  dev  eth0  parent  1:  classid  1:1  hfsc  sc  rate  
1000kbit  ul  rate  1000kbit 
tc  class  add  dev  eth0  parent  1:1  classid  1:10  hfsc  sc  rate  
500kbit  ul  rate  1000kbit 
tc  class  add  dev  eth0  parent  1:1  classid  1:20  hfsc  sc  rate  
500kbit  ul  rate  1000kbit 
tc  class  add  dev  eth0  parent  1:10  classid  1:11  hfsc  sc  umax  
1500b  dmax  53ms  rate  400kbit  ul  rate  1000kbit 
tc  class  add  dev  eth0  parent  1:10  classid  1:12  hfsc  sc  umax  
1500b  dmax  30ms  rate  100kbit  ul  rate  1000kbit
---------------
I had all traffic on eth0 stopped. Tried on br0 - same result. Even ARP 
becoming non-functional.

Stats:

tc -s class show dev br0
class hfsc 1: root
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 3

class hfsc 1:11 parent 1:10 sc m1 0bit d 23.0ms m2 400000bit ul m1 0bit d 0us 
m2 1000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 1:1 parent 1: sc m1 0bit d 0us m2 1000Kbit ul m1 0bit d 0us m2 
1000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 2

class hfsc 1:10 parent 1:1 sc m1 0bit d 0us m2 500000bit ul m1 0bit d 0us m2 
1000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 1

class hfsc 1:20 parent 1:1 sc m1 0bit d 0us m2 500000bit ul m1 0bit d 0us m2 
1000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 0

class hfsc 1:12 parent 1:10 sc m1 400000bit d 30.0ms m2 100000bit ul m1 0bit 
d 0us m2 1000Kbit
 Sent 0 bytes 0 pkt (dropped 0, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0
 period 0 level 0

tc -s qdisc show dev br0
qdisc hfsc 1: root
 Sent 0 bytes 0 pkt (dropped 3, overlimits 0 requeues 0)
 rate 0bit 0pps backlog 0b 0p requeues 0

After specifying correct default class everything worked fine.

In HTB if you dont specify default class, traffic just pass without 
"shaping". 
Is it possible to keep same behaviour on both disciplines?
Probably just dropping all traffic not good idea, cause if user working on 
remote box by forgetting specifying default class or by mistake using 
incorrect class number he will loose access to the box, if same interface is 
used for tests on shaping and access.
In same time it is good, and can show accurate results on shaping, without 
bypassing some "forgotten" traffic.
But at least it must be same, IMHO, on HTB and HFSC.

--
Denys Fedoryshchenko
Technical Manager
Virtual ISP S.A.L.

