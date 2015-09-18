From: Murali Karicheri <m-karicheri2@ti.com>
Subject: netdev: question on ndo_set_rx_mode() API
Date: Fri, 18 Sep 2015 13:07:27 -0400
Message-ID: <55FC44CF.8050001@ti.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"; format=flowed
Content-Transfer-Encoding: 7bit
To: open list: TI NETCP ETHERNET DRIVER <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, ;
Return-path: <netdev-owner@vger.kernel.org>
Received: from devils.ext.ti.com ([198.47.26.153]:44699 "EHLO
	devils.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753701AbbIRRHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Sep 2015 13:07:14 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Netdev experts,

I am seeing an issue with netcp driver that has a mutex lock/unlock() 
call. When kernel hack debug options are enabled, I see a warning that 
this function is taking a mutex that can sleep and is not allowed. I am 
working to fix this. Looking at other drivers, I see many drivers such 
as e1000_main.c are not holding any driver specific lock as part of the 
API implementation. So my first attempt is to remove the mutex. But 
wondering what kind of synchronization is required in this API to run it 
properly on an SMP kernel. Based on my search following files are 
calling dev_change_flags() which in turn calls ndo_set_rx_mode()

Set-1
======
net/ipv4/devinet.c
net/ipv4/ipconfig.c
net/core/dev_ioctl.c

Set-2
=====
net/8021q/vlan.c
net/core/rtnetlink.c

Set-1 seems to call this with rtnl_lock (mutex) held. So there is 
already protection between processes that calls this function and driver 
doesn't need to provide any explicit synchronization. Is this correct?

For Set-2, I can't figure out in what context this is calling this API 
Can someone help me understand this?

However I see below.

Documentation/networking/netdevices.txt explains,

ndo_set_rx_mode:
Synchronization: netif_addr_lock spinlock.
Context: BHs disabled

So is there any synchronization required from the driver perspective? If 
yes, what kind of synchronization is needed? Thanks in advance for your 
response.

-- 
Murali Karicheri
Linux Kernel, Keystone
