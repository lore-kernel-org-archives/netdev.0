From: Malcolm Scott <linux-netdev@malc.org.uk>
Subject: Re: accelerated vlan gives pcap tagged packets untagged
Date: Fri, 24 Jul 2009 17:50:26 +0100 (BST)
Message-ID: <alpine.DEB.2.00.0907241743180.12037@callisto.malc.org.uk>
References: <20090208123735.15d9ea4b@mjolnir.drzeus.cx> <49902E35.6060506@trash.net> <alpine.DEB.2.00.0907231656000.12037@callisto.malc.org.uk> <4A689159.2010807@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Pierre Ossman <drzeus-list@drzeus.cx>,
	Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from helene.retrosnub.co.uk ([78.129.234.8]:51322 "EHLO
	helene.retrosnub.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753327AbZGXQu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2009 12:50:27 -0400
In-Reply-To: <4A689159.2010807@trash.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

At 18:35 yesterday, Patrick McHardy wrote:

> Malcolm Scott wrote:
>
>> So to clarify: as of 2.6.28, an app (e.g. dhcpd) listening on eth0 will
>> by default see packets from all VLANs with tags removed; if it wishes to
>> do otherwise, it should query the kernel for the VLAN tag of every
>> packet and discard those with a tag?
>
> No, exactly the opposite. Starting with 2.6.28 and a recent libpcap,
> VLAN tags are present in userspace independant of whether the driver
> uses VLAN acceleration or not.

Sorry, I meant that the 802.1q header is removed from the packet, not 
discarded entirely.

>> In my case, this is manifesting as the DHCP misbehaviour which Pierre
>> mentioned.  (ISC dhcp3d does not use libpcap, and does not query the
>> packet socket for the VLAN tag, so it treats every VLAN's packets as for
>> the default VLAN.)
>
> It needs to get the VLAN tag from the auxilliary data.

Right.  But backwards compatibility with older apps is the issue.  An app 
which doesn't go looking for a VLAN tag in the auxiliary data -- because it 
didn't have to do so prior to 2.6.28 -- will start seeing packets from all 
VLANs rather than just the untagged ones.

Perhaps what's actually needed is another interface which sees _just_ the 
untagged packets, e.g. eth0.0 (0 being a reserved VLAN ID meaning 'no VLAN', 
i.e. equivalent to no 802.1q tag).

Malcolm

-- 
Malcolm Scott
University of Cambridge Computer Laboratory
