From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: active-backup/bonding with drivers not supporting set_mac_address()
Date: Tue, 11 Jul 2006 16:33:48 +0300
Message-ID: <44B3A8BC.9060306@voltaire.com>
References: <Pine.LNX.4.64.0607101618390.26558@zuben> <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:5491 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP
	id S1750765AbWGKNeB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 11 Jul 2006 09:34:01 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200607101829.k6AITEp0026893@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <ogerlitz@voltaire.com> wrote:
> 
>> Looking on the linux bonding driver, it seems to unconditionally (*)
>> assume that the enslaved device supports the set_mac_address call.
>>
>>From reading the doc (Documentation/networking/bonding.txt) i understand that
>> it is **not** a must prerequisite for the active-backup mode, this is since
>> there is at most one active slave at each point of time and as the doc states:
>>
>> 	when a failover occurs in active-backup mode, bonding will issue
>> 	one or more gratuitous ARPs on the newly active slave.
> 
> 	I think you're misreading the documentation a bit.  Some
> specific modes (balance-alb, for example) require that the slave device
> driver support set_mac_address while the device is up.  Many device
> drivers will only allow MAC changes while the device is down; those
> drivers won't work with the alb mode.
> 
> 	The active-backup and other modes have always needed a set_mac
> functionality, but they don't require that the device be up when
> changing the MAC (those modes set the mac for a slave one time, during
> the enslavement process, and the device is down when this is done).

Thanks for clarifying and sharpening this point; however thinking about 
set_mac_address for active-backup mode i could not convince myself that 
there is a **need** for that. However, at high level it does make some 
(much) sense that the bond net device exposes a mac which is not changed 
when the active slave changes.

> 	The purpose of the gratuitous ARP is to update switch forwarding
> tables (i.e., announce that the device has moved from one port to
> another), not to announce a change of MAC address.

I see, but it will have the affect of MAC address change announcement.

> 	I think changing active-backup (as an example here) to cause a
> MAC change during failover will have some side effects and secondary
> requirements that aren't necessarily obvious.  For example, the MAC of
> the bond itself will change during failover; I'm not sure right offhand
> what effect if any this might have on third parties.

I will be glad to know if you have more concrete ideas what would be the 
possible problems with such impl.

Or.

