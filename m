From: Joe Jin <joe.jin@oracle.com>
Subject: Broadcom 5709 take long time to bring up
Date: Wed, 18 Aug 2010 22:34:32 +0800
Message-ID: <20100818143432.GA29386@joejin-pc.cn.oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: joe.jin@oracle.com, terry.liu@oracle.com, netdev@vger.kernel.org
To: Michael Chan <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rcsinet10.oracle.com ([148.87.113.121]:54109 "EHLO
	rcsinet10.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753404Ab0HROgI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Aug 2010 10:36:08 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Michael,

We try boning two broadcom 5709 nics with active-backup mode, we try to
down/up one of the nics, I found some ping packets loss as below:
# ifdown eth0 
# ifup eth0  <-- no pkg loss 
# ifdown eth1 
# ifup eth1  <-- 2 pkg loss 
# ifdown eth0 
# ifup eth0  <-- 10 pkg loss 
# ifdown eth1 
# ifup eth1 <-- no pkg loss 
# ifdown eth0 
# ifup eth0  <-- 10 pkg loss 

module bond parameter are:
"mode=1 miimon=100 primary=eth0 downdelay=100 updelay=100"

we have tried the latest driver(2.0.8c) of broadcom and Redhat el5.5
official driver(2.0.2), result are same.

I checked and debugged the driver found it caused by take long time(~3s)
to bring up the device. here are link state when call if up:
# ifdown eth0 
# ifup eth0   
#ip -o link | grep eth0 
2: eth0: <BROADCAST,MULTICAST,SLAVE,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
# ifdown eth1 
# ifup eth1   
#ip -o link | grep eth1 
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
# ifdown eth0 
# ifup eth0   
#ip -o link | grep eth0 
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
# ifdown eth1 
# ifup eth1   
#ip -o link | grep eth1 
3: eth1: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 
# ifdown eth0 
# ifup eth0 
#ip -o link | grep eth0 
2: eth0: <NO-CARRIER,BROADCAST,MULTICAST,SLAVE,UP> mtu 1500 qdisc pfifo_fast master bond0 qlen 1000\    link/ether 00:26:55:4f:1f:18 brd ff:ff:ff:ff:ff:ff 

So, the question is how long alway will take when bring up the interface?
3 seconds as expection or no? if not, is that a firmware issure or driver
issue?

Thanks,
Joe



