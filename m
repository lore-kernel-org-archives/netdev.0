From: Zhu Yanjun <Yanjun.Zhu@windriver.com>
Subject: [PATCH 0/1] bridge: turn off carrier when the bridge is created
Date: Tue, 10 Mar 2015 15:09:41 +0800
Message-ID: <1425971382-14177-1-git-send-email-Yanjun.Zhu@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
To: <netdev@vger.kernel.org>, <davem@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:49298 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452AbbCJHJ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Mar 2015 03:09:28 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

V2:
   From Stephen, 
   "This is intentional. If there are no active ports in bridge, then
    we want to tell applications that packets will go nowhere."

V1:
  I made this test on ubuntu 14.04 with kernel 3,19-rc7:

  1. brctl addbr br0

  2. ifconfig br0 up

  3. ifconfig br0 (br0's status is with 'RUNNING')

  4. brctl addif br0 eth0

  5. brctl delif br0 eth0

  6. ifconfig br0 (br0's status is without 'RUNNING')

  When there is no sub-interface, the flag "RUNNING" is missing after the last sub-interface is removed.

  As such, should we keep "RUNNING" flag after the last sub-interface is removed? 


Zhu Yanjun (1):
  bridge: turn off carrier when the bridge is created

 net/bridge/br_device.c | 4 ++++
 1 file changed, 4 insertions(+)

-- 
1.9.1
