From: yinpeijun <yinpeijun@huawei.com>
Subject: vxlan gro problem ?
Date: Wed, 8 Oct 2014 16:46:58 +0800
Message-ID: <5434FA02.8070608@huawei.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <lichunhe@huawei.com>, <wangfakai@huawei.com>
To: <netdev@vger.kernel.org>, <linux-kernel@vger.kernel.org>,
	<ogerlitz@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from szxga03-in.huawei.com ([119.145.14.66]:51192 "EHLO
	szxga03-in.huawei.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755062AbaJHIra (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2014 04:47:30 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
        recently Linux 3.14 has been released and I find the networking has added udp gro and vxlan gro funtion, then I use the redhat 7.0(there is also add this funtion)
to test, I use kernel vxlan module and  create a vxlan device then attach the device to  ovs  bridge , the configure as follow:
       root@25:~$ ip link      
        15: vxlan0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1450 qdisc noqueue master ovs-system state UNKNOWN mode DEFAULT
            link/ether be:e1:ae:3d:8b:f2 brd ff:ff:ff:ff:ff:ff
        16: vnet0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1400 qdisc mq master ovs-system state UNKNOWN mode DEFAULT qlen 5000
       
       root@25:~$ ovs-vsctl show
        aa1294f3-9952-4393-b2b5-54e9a6eb76ee
        Bridge ovs-vx
            Port ovs-vx
                Interface ovs-vx
                    type: internal
            Port "vnet0"
                Interface "vnet0"
            Port "vxlan0"
                Interface "vxlan0"
        ovs_version: "2.0.2"

vnet0 is a vm backend device,  and the end is the same configuration. then I use netperf to test throughput  in vm (netperf -H **** -t TCP_STREAM -l 10 -- -m 1460), 
the result is 3-4 Gbit/sec, the  improvement  is not obvious,   and I also confused there is no aggregation  packets (length > mtu) in the end vm.   so I want to know what
wrong ?   or how to test the function ?
