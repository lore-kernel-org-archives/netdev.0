From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Network virtualization/isolation
Date: Wed, 25 Oct 2006 17:51:28 +0200
Message-ID: <453F8800.9070603@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate4.uk.ibm.com ([195.212.29.137]:30096 "EHLO
	mtagate4.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1751213AbWJYPv3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Oct 2006 11:51:29 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate4.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k9PFpSnh243300
	for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 15:51:28 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9PFs37t2441320
	for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 16:54:03 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9PFpRT3032326
	for <netdev@vger.kernel.org>; Wed, 25 Oct 2006 16:51:28 +0100
To: shemminger@osdl.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Stephen,

currently the work to make the container enablement into the kernel is 
doing good progress. The ipc, pid, utsname and filesystem system 
ressources are isolated/virtualized relying on the namespaces concept.

But, there is missing the network virtualization/isolation. Two 
approaches are proposed: doing the isolation at the layer 2 and at the 
layer 3.

The first one instanciate a network device by namespace and add a peer 
network device into the "root namespace", all the routing ressources are 
   relative to the namespace. This work is done by Andrey Savochkin from 
the openvz project.

The second relies on the routes and associates the network namespace 
pointer with each route. When the traffic is incoming, the packet 
follows an input route and retrieve the associated network namespace. 
When the traffic is outgoing, the packet, identified from the network 
namespace is coming from, follows only the routes matching the same 
network namespace. This work is made by me.

IMHO, we need the two approach, the layer-2 to be able to bring *very* 
strong isolation for system container with a performance cost and a 
layer-3 to be able to have good isolation for lightweight container or 
application container when performances are more important.

Do you have some suggestions ? What is your point of view on that ?

Thanks in advance.

   -- Daniel
