From: Murali Karicheri <m-karicheri2@ti.com>
Subject: IGMP on IPv6
Date: Wed, 22 Mar 2017 11:04:05 -0400
Message-ID: <58D29265.1020604@ti.com>
References: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
To: Hangbin Liu <liuhangbin@gmail.com>,
        "open list:TI NETCP ETHERNET DRIVER" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lelnx193.ext.ti.com ([198.47.27.77]:55014 "EHLO
        lelnx193.ext.ti.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1759638AbdCVPES (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 22 Mar 2017 11:04:18 -0400
In-Reply-To: <1479111388-25383-1-git-send-email-liuhangbin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Liu,

I saw that you have sent patches to the list for IGMP and have a question on IGMP on IPv6.
Hope you can clarify. I have posted the question already to the list and is reproduced
below. Let me know if you have an answer.

========= See email with subject "IPv6 IGMP issue in v4.4.44 ?? ========================
Cut-n-paste from that email....

I see an issue with IGMP for IPv6 when I test HSR redundancy network
interface. As soon as I set up an HSR interface, I see some IGMP messages
(destination mac address: 33 33 00 00 00 02 going over HSR interface to
slave interfaces, at the egress where as for IPv6, I see similar messages
going directly over the Ethernet interfaces that are attached to
HSR master. It appears that the NETDEV_CHANGEUPPER is not handled properly
and the mcast snoop sends the packets over the old interfaces at timer
expiry. 

A dump of the message at the slave Ethernet interface looks like below.

IPv4

[   64.643842] 33 33 00 00 00 02 70 ff 76 1c 0f 8d 89 2f 10 3e fc 
[   64.649910] 18 86 dd 60 00 00 00 00 10 3a ff fe 80 00 00 00 
[   64.655705] 00 00 00 72 ff 76 ff fe 1c 0f 8d ff 02 00 00 00 
[   64.661503] 00 00 00 00 00 00 00 00 00 00 02 85 00 8d dc 


You can see this is tagged with HSR.

IPv6

[   65.559130] 33 33 00 00 00 02 70 ff 76 1c 0f 8d 86 dd 60 00 00 
[   65.565205] 00 00 10 3a ff fe 80 00 00 00 00 00 00 72 ff 76 
[   65.571011] ff fe 1c 0f 8d ff 02 00 00 00 00 00 00 00 00 00 
[   65.576806] 00 00 00 00 02 85 00 8d dc 00 00 00 00 01 01 

This is going directly to the slave Ethernet interface.

When I put a WARN_ONCE, I found this is coming directly from 
mld_ifc_timer_expire() -> mld_sendpack() -> ip6_output()

Do you think this is fixed in latest kernel at master? If so, could
you point me to some commits.


-- 
Murali Karicheri
Linux Kernel, Keystone
