From: David Stevens <dlstevens@us.ibm.com>
Subject: Re: [PATCH net-next] add DOVE extensions for VXLAN
Date: Tue, 13 Nov 2012 17:28:17 -0500
Message-ID: <OFD9622F46.08427B4F-ON85257AB5.00792B0C-85257AB5.007B6F17@us.ibm.com>
References: <201211132022.qADKLMrT018535@lab1.dls> <20121113132842.2414d381@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:39394 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751474Ab2KMWcS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 17:32:18 -0500
Received: from /spool/local
	by e2.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <dlstevens@us.ibm.com>;
	Tue, 13 Nov 2012 17:29:37 -0500
Received: from d01relay04.pok.ibm.com (d01relay04.pok.ibm.com [9.56.227.236])
	by d01dlp03.pok.ibm.com (Postfix) with ESMTP id 8F797C90077
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 17:28:35 -0500 (EST)
Received: from d03av05.boulder.ibm.com (d03av05.boulder.ibm.com [9.17.195.85])
	by d01relay04.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id qADMSYfL031922
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 17:28:35 -0500
Received: from d03av05.boulder.ibm.com (loopback [127.0.0.1])
	by d03av05.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id qADMSPUB019256
	for <netdev@vger.kernel.org>; Tue, 13 Nov 2012 15:28:25 -0700
In-Reply-To: <20121113132842.2414d381@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stephen Hemminger <shemminger@vyatta.com> wrote on 11/13/2012 04:28:42 PM:

> 
> There are some issues with this.
>  1. DOVE flag is mixing multiple functions (arp and route) together,
>     users may want one without the other.

        I can separate these.

>  2. There is an implicit assumption that IP stack has valid IP address
>     in the tenant network (vxlan). This is rarely the case. For security
>     and other reasons, in my opinion the best practice is not to have
>     the bridge as part of the tenant network.

        No, actually for testing I didn't set an IP address on the tunnel
endpoint at all. The neighbor table entries must be in the domain, but
they are only used within the domain when the tunnel endpoint is on a
bridge and the host has no IP address on that interface.

>  3. Misses might be common and this could easily be used to DoS the host
>     from a malicious guest.

        Yes. The management piece can add forwarding table entries with
"0.0.0.0" as the dst IP address to disable MAC misses, and neighbor
table entries to disable IP misses, but it is our intention to have all
reachable destinations with both forwarding table and neighbor table
entries and no learning or multicast address (ie, no forwarding of 
anything
that isn't in the forwarding table). And yes, we want a notification
for every miss packet.
        Someone who doesn't want all of them shouldn't use this feature.
If we're dropping the "dove" flag in favor of individual flags for each
feature, then I could make this into "l2miss" and "l3miss" flags and
they should default off, of course.

                                                        +-DLS
