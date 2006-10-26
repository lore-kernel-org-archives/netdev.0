From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: Network virtualization/isolation
Date: Fri, 27 Oct 2006 00:16:53 +0200
Message-ID: <454133D5.8030307@fr.ibm.com>
References: <453F8800.9070603@fr.ibm.com>	<20061023130113.1430b95d@freekitty>	<45408397.8070404@fr.ibm.com> <20061026085659.33b4c6dd@freekitty>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.uk.ibm.com ([195.212.29.134]:50088 "EHLO
	mtagate1.uk.ibm.com") by vger.kernel.org with ESMTP
	id S1161154AbWJZWQx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Oct 2006 18:16:53 -0400
Received: from d06nrmr1407.portsmouth.uk.ibm.com (d06nrmr1407.portsmouth.uk.ibm.com [9.149.38.185])
	by mtagate1.uk.ibm.com (8.13.8/8.13.8) with ESMTP id k9QMGqXl200214
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 22:16:52 GMT
Received: from d06av03.portsmouth.uk.ibm.com (d06av03.portsmouth.uk.ibm.com [9.149.37.213])
	by d06nrmr1407.portsmouth.uk.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9QMJRVp2150520
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 23:19:27 +0100
Received: from d06av03.portsmouth.uk.ibm.com (loopback [127.0.0.1])
	by d06av03.portsmouth.uk.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9QMGpkW030468
	for <netdev@vger.kernel.org>; Thu, 26 Oct 2006 23:16:51 +0100
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20061026085659.33b4c6dd@freekitty>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> On Thu, 26 Oct 2006 11:44:55 +0200
> Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

[ ... ]

> Assuming you are talking about pseudo-virtualized environments,
> there are several different discussions.

Yes, exact, I forgot to mention that.

> 
> 1. How should the namespace be isolated for the virtualized containered
>    applications?

The network ressources should be related to the namespaces and 
especially the struct sock. So when a checkpoint is initiated for the 
container, you can identify the established connection, the timewait 
socket, the req queues, ... related to the container in order to freeze 
the traffic and checkpoint them.
The IP addresses are not a valid discrimator for identifiying,  for 
example if you have several containers interconnected into the same host.

> 
> 2. How should traffic be restricted into/out of those containers. This
>    is where existing netfilter, classification, etc, should be used.
>    The network code is overly rich as it is, we don't need another
>    abstraction.

Using only the netfilters you will be not able to bind to the same 
INADDR_ANY,port in different containers. You will need to handle several 
IP addresses coming from IP aliasing and check source address to be sure 
the source address is related to the right container and not from a 
primary interface probably assigned to a different container.
> 
> 3. Can the virtualized containers be secure? No. we really can't keep
>    hostile root in a container from killing system without going to
>    a hypervisor.

That is totally true, the containers don't aim to replace 
full-virtualized environment.

