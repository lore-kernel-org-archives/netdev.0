From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network virtualization/isolation
Date: Mon, 23 Oct 2006 13:01:13 -0700
Message-ID: <20061023130113.1430b95d@freekitty>
References: <453F8800.9070603@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35267 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932261AbWJYQH2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2006 12:07:28 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <453F8800.9070603@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 25 Oct 2006 17:51:28 +0200
Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

> Hi Stephen,
> 
> currently the work to make the container enablement into the kernel is 
> doing good progress. The ipc, pid, utsname and filesystem system 
> ressources are isolated/virtualized relying on the namespaces concept.
> 
> But, there is missing the network virtualization/isolation. Two 
> approaches are proposed: doing the isolation at the layer 2 and at the 
> layer 3.
> 
> The first one instanciate a network device by namespace and add a peer 
> network device into the "root namespace", all the routing ressources are 
>    relative to the namespace. This work is done by Andrey Savochkin from 
> the openvz project.
> 
> The second relies on the routes and associates the network namespace 
> pointer with each route. When the traffic is incoming, the packet 
> follows an input route and retrieve the associated network namespace. 
> When the traffic is outgoing, the packet, identified from the network 
> namespace is coming from, follows only the routes matching the same 
> network namespace. This work is made by me.
> 
> IMHO, we need the two approach, the layer-2 to be able to bring *very* 
> strong isolation for system container with a performance cost and a 
> layer-3 to be able to have good isolation for lightweight container or 
> application container when performances are more important.
> 
> Do you have some suggestions ? What is your point of view on that ?
> 
> Thanks in advance.
> 
>    -- Daniel

Any solution should allow both and it should build on the existing netfilter infrastructure.


-- 
Stephen Hemminger <shemminger@osdl.org>
