From: Ben Greear <greearb@candelatech.com>
Subject: Re: BUG: soft lockup detected on CPU#0!  (2.6.18.2 plus hacks)
Date: Tue, 02 Jan 2007 15:43:47 -0800
Message-ID: <459AEE33.7080702@candelatech.com>
References: <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jarkao2@o2.pl, NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.lanforge.com ([66.165.47.211]:42415 "EHLO ns2.lanforge.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752710AbXABXn5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 2 Jan 2007 18:43:57 -0500
To: David Stevens <dlstevens@us.ibm.com>
In-Reply-To: <OFB8CE3E37.99FD5849-ON88257257.0080FAE8-88257257.00819B15@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Stevens wrote:
> I've looked at this a little too -- it'd be nice to know who holds
> the write lock.
> 
> I see ip_mc_destroy_dev() is bouncing through the lock for
> each multicast address, though it starts at the beginning of
> the list each time. I don't see a problem with it, but it'd be
> simpler if it acquired the write lock once, grabbed and nulled
> the list, released the lock and then called igmp_group_dropped()
> & ip_ma_put() on each address from the local list copy.
> 
> Are you destroying/creating interfaces or doing a lot of multicasting at
> the time? How many group memberships do you have?

Lots and lots of interfaces were being created...at least 200 mac-vlans (out-of tree patch
somewhat similar to 802.1q vlans.)  The avahi-daemon process was running, and it appears
to be adding a multicast to each interface.  It was spewing failure messages in /var/log/messages,
probably because it can't handle so many interfaces.

Other than that, there is no (known) multicast traffic being generated.

This bug was reported to me by a user in Australia, and we have not yet
attempted to recreate this locally, so I am not certain exactly what it
takes to trigger this bug.

Thanks,
Ben



> 
>                                         +-DLS


-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com

