From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Fri, 26 Sep 2008 12:09:17 -0700
Message-ID: <21283.1222456157@death.nxdomain.ibm.com>
References: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
Cc: Brian Haley <brian.haley@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: David Stevens <dlstevens@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:59983 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752103AbYIZTKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 26 Sep 2008 15:10:16 -0400
In-reply-to: <OFE12AA65F.345E597C-ON882574D0.00637542-882574D0.00679AFC@us.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Stevens <dlstevens@us.ibm.com> wrote:
>1) You're calling mld_send_report() directly, which will send the MLD
>        report synchronously. It should use the randomized timer (see 
>igmp6_join_group).
>        A mass failover (e.g., a power event in a cluster) would blast all 
>of these at once,
>        which is why the randomized timer is required for gratuitous 
>reports. This
>        should use a randomized timer, like mld_ifc_start_timer(), but 
>joining the
>        group all by itself will do that.

	I need to do some more reading to have an informed response on
this one (not that I don't believe you; I'm just not familiar with the
MLD specs).

>2) There is already a configurable and code for unsolicited neighbor 
>advertisements
>        when adding an address-- why not use that? In fact, wouldn't just 
>moving the
>        failing device's address list to the new device do everything you 
>want, since
>        adding an address already sends unsolicited neighbor 
>advertisements,
>        joins the solicited node address, etc.? Or am I missing something?

	Ooh, ooh, I can answer this one: The protocol addresses don't
move, they're attached to the bonding master.  The slaves have no
protocol level addresses of their own, so some kind of extra magic has
to take place.

>3) MLD has a lot of state and it's all associated with the device. 
>Changing the sending
>        device out from under it seems risky to me. I don't know enough 
>about
>        bonding, but I think you really just want all the group 
>memberships and
>        MLD state to be with the master device and the master should just 
>go
>        through the multicast list for the master and join those groups on 
>the
>        new slave. The MLD code will already resolve the filters 
>appropriately
>        for joins and filters already done directly on the new slave that 
>way.

	This sound analagous to the IPv4 multicast address handling,
wherein the multicast address list is moved from one slave to another.
Is that a reasonable parallel?

>                Actually, I thought that's what Jay's prior patch was all 
>about, and
>        those joins should trigger MLD reports where needed, so I'm 
>definitely
>        confused on what the problem with multicasts is beyond the 
>solicited-node
>        addresses (which just needs to mimic the address add code, or use 
>it
>        directly).

	I haven't posted any prior patch for this, so I'm not sure what
you're talking about here.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
