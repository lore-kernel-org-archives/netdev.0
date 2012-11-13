From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] add DOVE extensions for VXLAN
Date: Tue, 13 Nov 2012 13:28:42 -0800
Message-ID: <20121113132842.2414d381@nehalam.linuxnetplumber.net>
References: <201211132022.qADKLMrT018535@lab1.dls>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David L Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:42403 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751333Ab2KMV3p (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 16:29:45 -0500
In-Reply-To: <201211132022.qADKLMrT018535@lab1.dls>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 15:21:22 -0500
David L Stevens <dlstevens@us.ibm.com> wrote:

> 
> 	This patch provides extensions to VXLAN for supporting Distributed
> Overlay Virtual Ethernet (DOVE) networks. The patch includes:
> 
> 	+ a dove flag per VXLAN device to enable DOVE extensions
> 	+ ARP reduction, whereby a bridge-connected VXLAN tunnel endpoint
> 		answers ARP requests from the local bridge on behalf of
> 		remote DOVE clients
> 	+ route short-circuiting (aka L3 switching). Known destination IP
> 		addresses use the corresponding destination MAC address for
> 		switching rather than going to a (possibly remote) router first.
> 	+ netlink notification messages for forwarding table and L3 switching
> 		misses
> 
> Signed-off-by: David L Stevens <dlstevens@us.ibm.com>

I am happy to see VXLAN getting real traction.

There are some issues with this.
 1. DOVE flag is mixing multiple functions (arp and route) together,
    users may want one without the other.
 2. There is an implicit assumption that IP stack has valid IP address
    in the tenant network (vxlan). This is rarely the case. For security
    and other reasons, in my opinion the best practice is not to have
    the bridge as part of the tenant network.
 3. Misses might be common and this could easily be used to DoS the host
    from a malicious guest.

    
