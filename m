From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Thu, 26 Oct 2006 11:44:55 +0200
Message-ID: <45408397.8070404@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com> <20061023130113.1430b95d@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:57551 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1422961AbWJZJpO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 05:45:14 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k9Q9jCl8224160
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 09:45:13 GMT
Received: from d06av02.portsmouth.uk.ibm.com (d06av02.portsmouth.uk.ibm.com [9.149.37.228])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9Q9ll372437228
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 10:47:47 +0100
Received: from d06av02.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av02.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9Q9jB47013638
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 10:45:11 +0100
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061023130113.1430b95d@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Wed, 25 Oct 2006 17:51:28 +0200
> Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> 
> 
>>Hi Stephen,
>>
>>currently the work to make the container enablement into the kernel is 
>>doing good progress. The ipc, pid, utsname and filesystem system 
>>ressources are isolated/virtualized relying on the namespaces concept.
>>
>>But, there is missing the network virtualization/isolation. Two 
>>approaches are proposed: doing the isolation at the layer 2 and at the 
>>layer 3.
>>
>>The first one instanciate a network device by namespace and add a peer 
>>network device into the "root namespace", all the routing ressources are 
>>   relative to the namespace. This work is done by Andrey Savochkin from 
>>the openvz project.
>>
>>The second relies on the routes and associates the network namespace 
>>pointer with each route. When the traffic is incoming, the packet 
>>follows an input route and retrieve the associated network namespace. 
>>When the traffic is outgoing, the packet, identified from the network 
>>namespace is coming from, follows only the routes matching the same 
>>network namespace. This work is made by me.
>>
>>IMHO, we need the two approach, the layer-2 to be able to bring *very* 
>>strong isolation for system container with a performance cost and a 
>>layer-3 to be able to have good isolation for lightweight container or 
>>application container when performances are more important.
>>
>>Do you have some suggestions ? What is your point of view on that ?
>>
>>Thanks in advance.
>>
>>   -- Daniel
> 
> 
> Any solution should allow both and it should build on the existing netfilter infrastructure.
> 
> 

The problem is netfilter can not give a good isolation, eg. how can be 
handled netstat command ? or avoid to see IP addresses assigned to 
another container when doing ifconfig ? Furthermore, one of the biggest 
interest of the network isolation is to bring mobility with a container 
and that can only be done if the network ressources inside the kernel 
can be identified by container in order to checkpoint/restart them.

The all-in-namespace solution, ie. at layer 2, is very good in terms of 
isolation but it adds an non-negligeable overhead. The layer 3 isolation 
  has an insignifiant overhead, a good isolation perfectly adapted for 
applications containers.

Unfortunatly, from the point of view of implementation, layer 3 can not 
be a subset of layer 2 isolation when using "all-in-namespace" and layer 
2 isolation can not be a extension of the layer 3 isolation.

I think the layer 2 and the layer 3 implementations can coexists. You 
can for example create a system container with a layer 2 isolation and 
inside it add a layer 3 isolation.

Does that make sense ?

	-- Daniel




