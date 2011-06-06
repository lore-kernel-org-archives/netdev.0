From: BONNEAU Guy <gbonneau@miranda.com>
Subject: Multicast IP packet routed between 2 ports nic on the same host
Date: Mon, 6 Jun 2011 13:40:26 +0000
Message-ID: <24665DDC0D7CF047BD6471A56E615EA628ABF4DE@CA-OPS-MAILBOX.miranda.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ca-dr-mailacc.miranda.com ([199.202.148.221]:22194 "EHLO
	webmail.miranda.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752785Ab1FFNp5 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 09:45:57 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I am trying to receive multicast data packets from a multicast router to my Linux Ubuntu Desktop Workstation using kernel 2.6.35. The Linux Desktop has an Intel 82576 dual NIC adapter. Each NIC is configured to receive IP data from 2 different subnet. One is from 172.30.8.xx and another one from 10.0.xx.xx. Multicast IP data can only be received from 172.30.8.xx since there is no multicast source on subnet 10.0.xx.xx and IT that administrates the subnet 10.0.xx.xx disabled multicast capability of the switches and routers sitting on that subnet. The subnet 172.30.8.xx has multicast source broadcasting on multicast group 239.255.200.200:8000. 

I am using the application mreceived (version 2.2) from : http://www.cs.virginia.edu/~mngroup/software/ to test the network multicast set-up and capability of my Ubuntu Desktop Workstation. 

I open a first console and I use mreceive to join multicast group 239.255.200.200:8000 to receive multicast data from subnet 10.0.xx.xx using the console command : ./mreceive -g 239.255.200.200 -p 8000 -i 10.0.9.164 to the eth0 adapter of my workstation. The application is idle and no multicast data is received. This is the expected behaviour.

I open a second console and I use mreceive to join the same multicast group 239.255.200.200:8000 to receive multicast data from subnet 172.30.8.xx using the console command : ./mreceive -g 239.255.200.200 -p 8000 -i 172.30.8.31 to the eth1 adapter of my workstation. The application starts to receive multicast data and advertises the data received. This is also the expected behaviour.

Now this is where the problem begins. As soon as the multicast data begin to be received on the eth1 adapter the first console begins to advertise multicast data received on eth0 adapter. I am well aware that the Linux kernel implements a multicast level 2 routing capability. Thus at first glance this seems to be the expected behaviour. However... I have forwarding disabled as well as mc_forwarding disabled and rp_filter is enabled for both adapters. Thus I don't expect the kernel to forward the multicast data from eth1 to eth0. 

I have recompiled the kernel with IP Multicast Routing disabled and got the same behavior. I also tried kernel 2.6.38 and had the same issue.

At this point I am inclined to think that the kernel multicast routing might have an issue? I might have missing a network configuration setting but at this point I am baffled.  I checked the kernel bugbase with the multicast tagging and couldn't find a filled bug regarding this matter. The only remaining options for me are to fill a bug and trace the kernel code (ipmr.c) to understand what going on. Can someone shade light on this? Is this an expected behavior or an issue?

Thanks
GB 
      
