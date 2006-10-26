From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: Network virtualization/isolation
Date: Thu, 26 Oct 2006 08:56:59 -0700
Message-ID: <20061026085659.33b4c6dd@freekitty>
References: <453F8800.9070603@fr.ibm.com>
	<20061023130113.1430b95d@freekitty>
	<45408397.8070404@fr.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:142 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1161397AbWJZQCm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Oct 2006 12:02:42 -0400
To: Daniel Lezcano <dlezcano@fr.ibm.com>
In-Reply-To: <45408397.8070404@fr.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 26 Oct 2006 11:44:55 +0200
Daniel Lezcano <dlezcano@fr.ibm.com> wrote:

> Stephen Hemminger wrote:
> > On Wed, 25 Oct 2006 17:51:28 +0200
> > Daniel Lezcano <dlezcano@fr.ibm.com> wrote:
> > 
> > 
> >>Hi Stephen,
> >>
> >>currently the work to make the container enablement into the kernel is 
> >>doing good progress. The ipc, pid, utsname and filesystem system 
> >>ressources are isolated/virtualized relying on the namespaces concept.
> >>
> >>But, there is missing the network virtualization/isolation. Two 
> >>approaches are proposed: doing the isolation at the layer 2 and at the 
> >>layer 3.
> >>
> >>The first one instanciate a network device by namespace and add a peer 
> >>network device into the "root namespace", all the routing ressources are 
> >>   relative to the namespace. This work is done by Andrey Savochkin from 
> >>the openvz project.
> >>
> >>The second relies on the routes and associates the network namespace 
> >>pointer with each route. When the traffic is incoming, the packet 
> >>follows an input route and retrieve the associated network namespace. 
> >>When the traffic is outgoing, the packet, identified from the network 
> >>namespace is coming from, follows only the routes matching the same 
> >>network namespace. This work is made by me.
> >>
> >>IMHO, we need the two approach, the layer-2 to be able to bring *very* 
> >>strong isolation for system container with a performance cost and a 
> >>layer-3 to be able to have good isolation for lightweight container or 
> >>application container when performances are more important.
> >>
> >>Do you have some suggestions ? What is your point of view on that ?
> >>
> >>Thanks in advance.
> >>
> >>   -- Daniel
> > 
> > 
> > Any solution should allow both and it should build on the existing netfilter infrastructure.
> > 
> > 
> 
> The problem is netfilter can not give a good isolation, eg. how can be 
> handled netstat command ? or avoid to see IP addresses assigned to 
> another container when doing ifconfig ? Furthermore, one of the biggest 
> interest of the network isolation is to bring mobility with a container 
> and that can only be done if the network ressources inside the kernel 
> can be identified by container in order to checkpoint/restart them.
> 
> The all-in-namespace solution, ie. at layer 2, is very good in terms of 
> isolation but it adds an non-negligeable overhead. The layer 3 isolation 
>   has an insignifiant overhead, a good isolation perfectly adapted for 
> applications containers.
> 
> Unfortunatly, from the point of view of implementation, layer 3 can not 
> be a subset of layer 2 isolation when using "all-in-namespace" and layer 
> 2 isolation can not be a extension of the layer 3 isolation.
> 
> I think the layer 2 and the layer 3 implementations can coexists. You 
> can for example create a system container with a layer 2 isolation and 
> inside it add a layer 3 isolation.
> 
> Does that make sense ?
> 
> 	-- Daniel

Assuming you are talking about pseudo-virtualized environments,
there are several different discussions.

1. How should the namespace be isolated for the virtualized containered
   applications?

2. How should traffic be restricted into/out of those containers. This
   is where existing netfilter, classification, etc, should be used.
   The network code is overly rich as it is, we don't need another
   abstraction.

3. Can the virtualized containers be secure? No. we really can't keep
   hostile root in a container from killing system without going to
   a hypervisor.





-- 
Stephen Hemminger <shemminger@osdl.org>
