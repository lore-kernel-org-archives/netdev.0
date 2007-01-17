From: Daniel Lezcano <dlezcano@fr.ibm.com>
Subject: Re: [PATCH 0/12] L2 network namespace (v3)
Date: Wed, 17 Jan 2007 17:10:51 +0100
Message-ID: <45AE4A8B.6000206@fr.ibm.com>
References: <200701171851.14734.dim@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: containers@lists.osdl.org, alexey@sw.ru, saw@sw.ru,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate1.de.ibm.com ([195.212.29.150]:24680 "EHLO
	mtagate1.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932543AbXAQQLW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Jan 2007 11:11:22 -0500
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate1.de.ibm.com (8.13.8/8.13.8) with ESMTP id l0HGBKNx103900
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 16:11:20 GMT
Received: from d12av02.megacenter.de.ibm.com (d12av02.megacenter.de.ibm.com [9.149.165.228])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v8.2) with ESMTP id l0HGBJ9X3231758
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 17:11:19 +0100
Received: from d12av02.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av02.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id l0HGBIop007621
	for <netdev@vger.kernel.org>; Wed, 17 Jan 2007 17:11:19 +0100
To: Dmitry Mishin <dim@openvz.org>
In-Reply-To: <200701171851.14734.dim@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dmitry Mishin wrote:
> This is an update of L2 network namespaces patches. They are applicable
> to Cedric's 2.6.20-rc4-mm1-lxc2 tree. 
> 
> Changes:
> 	- updated to 2.6.20-rc4-mm1-lxc2
> 	- current network context is per-CPU now
> 	- fixed compilation without CONFIG_NET_NS
> 
> Changed current context definition should fix all mentioned by Cedric issues:
> 	- the nsproxy backpointer is unnecessary now - thus removed; 
> 	- the push_net_ns() and pop_net_ns() use per-CPU variable now;
> 	- there is no race on ->nsproxy between push_net_ns() and
> 	  exit_task_namespaces() because they deals with differrent pointers.
> 
> ===================================
> L2 network namespaces
> 
> The most straightforward concept of network virtualization is complete
> separation of namespaces, covering device list, routing tables, netfilter
> tables, socket hashes, and everything else.
> 
> On input path, each packet is tagged with namespace right from the
> place where it appears from a device, and is processed by each layer
> in the context of this namespace.
> Non-root namespaces communicate with the outside world in two ways: by
> owning hardware devices, or receiving packets forwarded them by their parent
> namespace via pass-through device.
> 
> This complete separation of namespaces is very useful for at least two
> purposes:
>   - allowing users to create and manage by their own various tunnels and
>     VPNs, and
>   - enabling easier and more straightforward live migration of groups of
>     processes with their environment.

Great ! Thanks Dmitry.
