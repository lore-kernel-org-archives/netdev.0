From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [RFC] network namespaces
Date: Thu, 07 Sep 2006 10:25:56 +0200
Message-ID: <44FFD794.7010802@fr.ibm.com>
References: <54AD0F12E08D1541B826BE97C98F99F1963B59@NT-SJCA-0751.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ebiederm@xmission.com, Kir Kolyshkin <kir@openvz.org>,
	devel@openvz.org, Andrey Savochkin <saw@sw.ru>, alexey@sw.ru,
	Linux Containers <containers@lists.osdl.org>,
	netdev@vger.kernel.org, sam@vilain.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate3.uk.ibm.com ([195.212.29.136]:59042 "EHLO
	mtagate3.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751072AbWIGI0C (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Sep 2006 04:26:02 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate3.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k878PxpM048580
	for <netdev@vger.kernel.org>; Thu, 7 Sep 2006 09:25:59 +0100
Received: from d06av04.portsmouth.uk.ibm.com (d06av04.portsmouth.uk.ibm.com [9.149.37.216])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k878S57K1589384
	for <netdev@vger.kernel.org>; Thu, 7 Sep 2006 09:28:05 +0100
Received: from d06av04.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av04.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k878Pvid001200
	for <netdev@vger.kernel.org>; Thu, 7 Sep 2006 09:25:58 +0100
To: Caitlin Bestler <caitlinb@broadcom.com>
In-Reply-To: <54AD0F12E08D1541B826BE97C98F99F1963B59@NT-SJCA-0751.brcm.ad.broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Caitlin Bestler wrote:
> ebiederm@xmission.com wrote:
>  
> 
>>>Finally, as I understand both network isolation and network
>>>virtualization (both level2 and level3) can happily co-exist. We do
>>>have several filesystems in kernel. Let's have several network
>>>virtualization approaches, and let a user choose. Is that makes
>>>sense? 
>>
>>If there are not compelling arguments for using both ways of
>>doing it is silly to merge both, as it is more maintenance overhead.
>>
> 
> 
> My reading is that full virtualization (Xen, etc.) calls for
> implementing
> L2 switching between the partitions and the physical NIC(s).
> 
> The tradeoffs between L2 and L3 switching are indeed complex, but
> there are two implications of doing L2 switching between partitions:
> 
> 1) Do we really want to ask device drivers to support L2 switching for
>    partitions and something *different* for containers?
> 
> 2) Do we really want any single packet to traverse an L2 switch (for
>    the partition-style virtualization layer) and then an L3 switch
>    (for the container-style layer)?
> 
> The full virtualization solution calls for virtual NICs with distinct
> MAC addresses. Is there any reason why this same solution cannot work
> for containers (just creating more than one VNIC for the partition, 
> and then assigning each VNIC to a container?)

IHMO, I think there is one reason. The unsharing mechanism is not only 
for containers, its aim other kind of isolation like a "bsdjail" for 
example. The unshare syscall is flexible, shall the network unsharing be 
one-block solution ? For example, we want to launch an application using 
TCP/IP and we want to have an IP address only used by the application, 
nothing more.
With a layer 2, we must after unsharing:
  1) create a virtual device into the application namespace
  2) assign an IP address
  3) create a virtual device pass-through in the root namespace
  4) set the virtual device IP

All this stuff, need a lot of administration (check mac addresses 
conflicts, check interface names collision in root namespace, ...) for a 
simple network isolation.

With a layer 3:
  1) assign an IP address

In the other hand, a layer 3 isolation is not sufficient to reach the 
level of isolation/virtualization needed for the system containers.

Very soon, I will commit more info at:

http://wiki.openvz.org/Containers/Networking

So the consensus is based on the fact that there is a lot of common code 
for the layer 2 and layer 3 isolation/virtualization and we can find a 
way to merge the 2 implementation in order to have a flexible network 
virtualization/isolation.

   -- Regards

	Daniel.


