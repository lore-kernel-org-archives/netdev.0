From: Brian Haley <brian.haley@hp.com>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Wed, 24 Sep 2008 17:07:53 -0400
Message-ID: <48DAAC29.6000108@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com> <48DA71A8.5050900@hp.com> <7958.1222288188@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Vlad Yasevich <vladislav.yasevich@hp.com>,
	Alex Sidorenko <alexandre.sidorenko@hp.com>,
	Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0015.houston.hp.com ([15.201.24.18]:35642 "EHLO
	g4t0015.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751436AbYIXVH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 17:07:57 -0400
In-Reply-To: <7958.1222288188@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jay Vosburgh wrote:
> Vlad Yasevich <vladislav.yasevich@hp.com> wrote:
> [...]
>> It doesn't.  What appears to happen in the active-backup case the MLD reports
>> are not generated on all of the slave devices, just the active one.  Thus the
>> switch knows only about the active device.
> 
> 	This behavior is by design.  Previously, it worked the other way
> (every slave did IPv6 addrconf stuff, etc), but that confused the
> switches because they'd snoop the addrconf traffic whenever a backup
> slave came up, and update the switch forwarding table.
> 
>> When you force the failover, no reports happen because the device believes that
>> the MLD group was already reported.  Thus there needs to be some trigger after
>> the failover to tell the switch that the mac address and multicast group have
>> moved to a different port.
> 
> 	Yes, there needs to be an ipv6 equivalent of the gratuitous ARP
> and IGMP rejoin that's done for ipv4.  I haven't figured out how to
> accomplish that yet; suggestions are welcome.

I have a patch that does it, just doing some final testing before 
sending it out, hopefully later today...

-Brian
