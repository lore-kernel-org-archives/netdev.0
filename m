From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Thu, 25 Sep 2008 08:07:22 -0700
Message-ID: <17219.1222355242@death.nxdomain.ibm.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com> <48DAFB92.7040904@hp.com>
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Brian Haley <brian.haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e1.ny.us.ibm.com ([32.97.182.141]:39408 "EHLO e1.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750733AbYIYPId (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Sep 2008 11:08:33 -0400
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e1.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m8PF8WSh022472
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 11:08:32 -0400
Received: from d01av03.pok.ibm.com (d01av03.pok.ibm.com [9.56.224.217])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id m8PF7WH9252678
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 11:07:32 -0400
Received: from d01av03.pok.ibm.com (loopback [127.0.0.1])
	by d01av03.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m8PF7W3a008813
	for <netdev@vger.kernel.org>; Thu, 25 Sep 2008 11:07:32 -0400
In-reply-to: <48DAFB92.7040904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley <brian.haley@hp.com> wrote:

>This is an RFC patch to add better IPv6 failover support for bonding
>devices, especially when in active-backup mode, as reported by Alex
>Sidorenko.
>
>What this patch does:
>
>- Creates a new Kconfig option in the IPv6 Networking section to
>  compile-in the support in the bonding driver.  This also forces
>  IPV6=y since that's required to link everything.

	I think it's probably better to have the IPV6 dependent bits
somehow depend on CONFIG_IPV6 rather than having a Kconfig entry.  I
doubt that many real-world users will say yes to IPv6 and bonding, but
no to the bonding IPv6 support.  I also suspect that the IPV6=y
requirement won't fly with distros.

>- Creates a new file, net/drivers/bonding/bond_ipv6.c, for the
>  IPv6-specific routines.

	Handy.

>- Adds a new master_ipv6 address member to the bonding struct to
>  hold a copy of the primary IPv6 address on the bond.

	Do we need to issue an NS for each ipv6 address, or is one
sufficient?

	Do ipv6 addresses configured on VLANs need one (or more) NS per
VLAN?

>- Adds a new tunable, num_grat_ns, to limit the number of gratuitous
>  Neighbor Solicitations that are sent on a failover event.  Default
>  is 1.
>
>On failover, this new code will generate two packets:
>
>- An MLD report for the bond, on the current active slave.
>
>- An IPv6 "gratuitous" Neighbor Solicitation, which helps the switch
>  learn that the address has moved to the new slave.
>
>Testing has shown that sending just the NS results in pretty good behavior
>when in active-back mode, I saw no lost ping packets for example.  Sending
>just the MLD packet didn't seem to have the same effect.  Sending both
>seems like the right thing to do.

	 I haven't tried the patch yet, so I'll comment further once
I've had a chance to test it (which may not be until tomorrow).

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
