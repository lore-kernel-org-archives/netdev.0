From: Brian Haley <brian.haley@hp.com>
Subject: Re: [RFC] bonding: add better ipv6 failover support
Date: Thu, 25 Sep 2008 11:42:57 -0400
Message-ID: <48DBB181.9050205@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com> <48DAFB92.7040904@hp.com> <17219.1222355242@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:32571 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752105AbYIYPnA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Sep 2008 11:43:00 -0400
In-Reply-To: <17219.1222355242@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Brian Haley <brian.haley@hp.com> wrote:
> 
>> This is an RFC patch to add better IPv6 failover support for bonding
>> devices, especially when in active-backup mode, as reported by Alex
>> Sidorenko.
>>
>> What this patch does:
>>
>> - Creates a new Kconfig option in the IPv6 Networking section to
>>  compile-in the support in the bonding driver.  This also forces
>>  IPV6=y since that's required to link everything.
> 
> 	I think it's probably better to have the IPV6 dependent bits
> somehow depend on CONFIG_IPV6 rather than having a Kconfig entry.  I
> doubt that many real-world users will say yes to IPv6 and bonding, but
> no to the bonding IPv6 support.  I also suspect that the IPV6=y
> requirement won't fly with distros.

I'm sure there's a way to do this better, for example, SCTP can be built 
as a module with IPv6 support and have IPV6=m.  I'll try to make it work 
without the option when IPV6=y or m.

>> - Adds a new master_ipv6 address member to the bonding struct to
>>  hold a copy of the primary IPv6 address on the bond.
> 
> 	Do we need to issue an NS for each ipv6 address, or is one
> sufficient?

It didn't seem like it from my testing, that single NS was enough to 
wake-up the switch when pinging either the link-local or global.  I'd 
have to add another global with a different prefix and re-test.

> 	Do ipv6 addresses configured on VLANs need one (or more) NS per
> VLAN?

I didn't test with VLANs, there would probably need to be some 
additional work there.

> 	 I haven't tried the patch yet, so I'll comment further once
> I've had a chance to test it (which may not be until tomorrow).

Thanks,

-Brian
