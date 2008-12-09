From: Benjamin Thery <benjamin.thery@bull.net>
Subject: Re: [PATCH 0/8] netns: make IPv6 multicast forwarding per-namespace
Date: Tue, 09 Dec 2008 17:56:03 +0100
Message-ID: <493EA323.5050806@bull.net>
References: <20081208160156.343758157@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev <netdev@vger.kernel.org>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Daniel Lezcano <dlezcano@fr.ibm.com>
To: Dave Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ecfrec.frec.bull.fr ([129.183.4.8]:43913 "EHLO
	ecfrec.frec.bull.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753398AbYLIQ4G (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Dec 2008 11:56:06 -0500
In-Reply-To: <20081208160156.343758157@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dave,

While doing some more tests on the patchset I've realized that the queue
of unresolved entries (mfc_unres_queue) should also be allocated
per-netns (or at least counter cache_resolve_queue_len should be).

With the current patchset, the cache for unresolved entries is limited
to 10 entries for all namespaces. D'oh.

I'm looking at this issue and  will resend the patchset with the missing
patch ASAP.

Benjamin

Benjamin Thery wrote:
> This patchset introduces the support for network namespaces in IPv6
> multicast forwarding code (net/ipv6/ip6mr.c).
> 
> The first patches in the series moves global data from ip6mr.c into 
> struct netns_ipv6 to prepare netns support. Data are still referenced in
> init_net only. One of these patches makes the related /proc entries
> per-namespace.
> 
> The last patch does the main job and enables the network namespace support
> by replacing all the init_net references with the proper net retrieved
> from sockets or net devices.
> 
> The patchset applies on top of net-next-2.6
> 
> Regards,
> Benjamin
> 
> 
> 


-- 
B e n j a m i n   T h e r y  - BULL/DT/Open Software R&D

    http://www.bull.com
