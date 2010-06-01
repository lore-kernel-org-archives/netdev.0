From: "Mr. Berkley Shands" <bshands@exegy.com>
Subject: 2.6.32 and Multicast group membership
Date: Tue, 01 Jun 2010 16:39:00 -0500
Message-ID: <4C057DF4.3000305@exegy.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: Net Dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 205.158.150.226.ptr.us.xo.net ([205.158.150.226]:15020 "EHLO
	mail.exegy.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753044Ab0FAVyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jun 2010 17:54:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

starting in 2.6.32, my multicast connections stop getting data after 
60-100 seconds.
The identical user code works fine under 2.6.22 through 2.6.31.

The NIC (an intel 82586) has two ports on the same subnet
(eth0 at 172.16.21.55/24 and eth1 at 172.16.21.56/24)

      if (setsockopt(sock, IPPROTO_IP, IP_ADD_MEMBERSHIP, (char*)&req, 
sizeof(req)))
      {
         perror("setsockopt IP_ADD_MEMBERSHIP failed");
         ::exit(-1);
      }

If I do ADD_MEMBERSHIP on just one of these interfaces, the sockets 
still get data.
But if I join on both interfaces, one or both will stop getting packets
after 60-100 seconds. Sniffing with tcpdump shows the Cisco layer 3 switch
is not getting its responses back to keep the multicast group open.
The HP layer 2 switch does not seem to care, it keeps the data flowing 
regardless
of which physical port the join is executed on.

Changing IP_MULTICAST_ALL has no effect :-(
Did I miss something? New code that I have to specify to keep the Cisco 
happy?

tia

Berkley


-- 

// E. F. Berkley Shands, MSc//

** Exegy Inc.**

349 Marshall Road, Suite 100

St. Louis , MO  63119

Direct:  (314) 218-3600 X450

Cell:  (314) 303-2546

Office:  (314) 218-3600

Fax:  (314) 218-3601

 

The Usual Disclaimer follows...

 


