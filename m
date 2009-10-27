From: Rick Jones <rick.jones2@hp.com>
Subject: Re: [PATCH] Multicast packet reassembly can fail
Date: Tue, 27 Oct 2009 16:22:51 -0700
Message-ID: <4AE780CB.8070401@hp.com>
References: <1256683583.3153.389.camel@linux-1lbu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Steve Chen <schen@mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g6t0187.atlanta.hp.com ([15.193.32.64]:38142 "EHLO
	g6t0187.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755902AbZJ0XWv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2009 19:22:51 -0400
In-Reply-To: <1256683583.3153.389.camel@linux-1lbu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Steve Chen wrote:
> Multicast packet reassembly can fail
> 
> When multicast connections with multiple fragments are received by the same
> node from more than one Ethernet ports, race condition between fragments
> from each Ethernet port can cause fragment reassembly to fail leading to
> packet drop.  This is because packets from each Ethernet port appears identical
> to the the code that reassembles the Ethernet packet.
> 
> The solution is evaluate the Ethernet interface number in addition to all other
> parameters so that every packet can be uniquely identified.  The existing
> iif field in struct ipq is now used to generate the hash key, and iif is also
> used for comparison in case of hash collision.
> 
> Please note that q->saddr ^ (q->iif << 5) is now being passed into
> ipqhashfn to generate the hash key.  This is borrowed from the routing
> code.
> 
> Signed-off-by: Steve Chen <schen@mvista.com>
> Signed-off-by: Mark Huth <mhuth@mvista.com>

It has been hours since my last good Emily Litella moment so I'll ask - isn't 
the combination of source and dest addr, protocol, IP ID and fragment offset 
supposed to take care of this?  How does the ingress interface have anything to 
do with it?

rick jones
