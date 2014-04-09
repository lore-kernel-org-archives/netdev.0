From: Heiner Kallweit <heiner.kallweit@web.de>
Subject: Re: ipv6: Should inet6_addr_del consider IFA_F_MANAGETEMPADDR?
Date: Wed, 09 Apr 2014 21:38:27 +0200
Message-ID: <5345A1B3.1010508@web.de>
References: <53443F5D.6030509@web.de> <20140408201430.GD27255@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.web.de ([212.227.15.4]:51751 "EHLO mout.web.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933342AbaDITjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 9 Apr 2014 15:39:16 -0400
In-Reply-To: <20140408201430.GD27255@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 08.04.2014 22:14, schrieb Hannes Frederic Sowa:
> [cc Jiri + Thomas]
>
> Hi!
>
> On Tue, Apr 08, 2014 at 08:26:37PM +0200, Heiner Kallweit wrote:
>> I stumbled accross the fact that inet6_addr_add as well as inet6_addr_modify
>> consider IFA_F_TEMPORARY whilst inet6_addr_del does not.
>>
>> My understanding of IFA_F_MANAGETEMPADDR is that it allows userspace applications
>> to deal with temporary addresses w/o having to create / track (and possibly delete)
>> each and every temporary address.
>>
>> This works fine when creating / modifying a global address. However when a
>> global address is deleted the orphaned temporary addresses remain.
>> Shouldn't the userspace be able to set IFA_F_MANAGETEMPADDR also for RTM_DELADDR
>> to signalize that the kernel should delete all related temporary addresses as well?
> Sure, that is possible. I guess it was not done already because
> inet6_addr_del did not handle IFA_FLAGS at all. But it should be a very
> tiny change to pass that flag down. Please submit an iproute patch along
> with your changes.
After a brief look at the source code of iproute2 it seems like "ip addr del" already supports sending
IFA_F_MANAGETEMPADDR with RTM_DELADDR, though I have the impression it's unintentional.

The del command internally calls ipaddr_modify just like add / change / replace.
And ipaddr_modify happily populates every flag provided on the command line w/o checking whether
the flag is applicable for the respective command.

Having said this only the usage info needs to be extended.
Not sure: Should the related patch go to this mailing list or to Stephen directly who seems to be the
current maintainer.

>> It would be a rather small extension to manage_tempaddrs to add a "delete" parameter
>> and set valid_lft=prefered_lft=0 for each temporary address if set.
> I think valid_lft=prefered_lft=0; manage_tempaddr(...);
> addrconf_verify_rtnl(); is enough to clean up the old temporary address.
> No need for a further flag.
Right .. Will prepare a patch.

>
>> Sorry if this was discussed before and I miss something.
> I don't remember a discussion about that. ;)
>
> Bye,
>
>   Hannes
>
Rgds, Heiner
