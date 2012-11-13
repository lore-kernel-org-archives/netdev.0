From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH net-next] add DOVE extensions for VXLAN
Date: Tue, 13 Nov 2012 14:41:48 -0800
Message-ID: <20121113144148.66a86bc7@nehalam.linuxnetplumber.net>
References: <201211132022.qADKLMrT018535@lab1.dls>
	<20121113132842.2414d381@nehalam.linuxnetplumber.net>
	<OFD9622F46.08427B4F-ON85257AB5.00792B0C-85257AB5.007B6F17@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:43639 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754385Ab2KMWmw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 17:42:52 -0500
In-Reply-To: <OFD9622F46.08427B4F-ON85257AB5.00792B0C-85257AB5.007B6F17@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 13 Nov 2012 17:28:17 -0500
David Stevens <dlstevens@us.ibm.com> wrote:

> Stephen Hemminger <shemminger@vyatta.com> wrote on 11/13/2012 04:28:42 PM:
> 
> > 
> > There are some issues with this.
> >  1. DOVE flag is mixing multiple functions (arp and route) together,
> >     users may want one without the other.
> 
>         I can separate these.
> 
> >  2. There is an implicit assumption that IP stack has valid IP address
> >     in the tenant network (vxlan). This is rarely the case. For security
> >     and other reasons, in my opinion the best practice is not to have
> >     the bridge as part of the tenant network.
> 
>         No, actually for testing I didn't set an IP address on the tunnel
> endpoint at all. The neighbor table entries must be in the domain, but
> they are only used within the domain when the tunnel endpoint is on a
> bridge and the host has no IP address on that interface.
> 
> >  3. Misses might be common and this could easily be used to DoS the host
> >     from a malicious guest.
> 
>         Yes. The management piece can add forwarding table entries with
> "0.0.0.0" as the dst IP address to disable MAC misses, and neighbor
> table entries to disable IP misses, but it is our intention to have all
> reachable destinations with both forwarding table and neighbor table
> entries and no learning or multicast address (ie, no forwarding of 
> anything
> that isn't in the forwarding table). And yes, we want a notification
> for every miss packet.
>         Someone who doesn't want all of them shouldn't use this feature.
> If we're dropping the "dove" flag in favor of individual flags for each
> feature, then I could make this into "l2miss" and "l3miss" flags and
> they should default off, of course.
> 
>                                                         +-DLS

Maybe a OVS style "here is the homeless packet" message is needed.
That would allow for controller in user space to populate table
on as needed basis.
