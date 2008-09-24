From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: Bonding and Neighbour Discovery on IPv6-only devices
Date: Wed, 24 Sep 2008 12:58:16 -0400
Message-ID: <48DA71A8.5050900@hp.com>
References: <200809151335.16817.asid@hp.com> <20080915180015.GB1078@havoc.gtf.org> <200809151416.49447.alexandre.sidorenko@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jeff@garzik.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Alex Sidorenko <alexandre.sidorenko@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g5t0007.atlanta.hp.com ([15.192.0.44]:19002 "EHLO
	g5t0007.atlanta.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754949AbYIXQ6S (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Sep 2008 12:58:18 -0400
In-Reply-To: <200809151416.49447.alexandre.sidorenko@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alex Sidorenko wrote:
> On September 15, 2008 02:00:15 pm Jeff Garzik wrote:
>> On Mon, Sep 15, 2008 at 01:35:16PM -0400, Alex Sidorenko wrote:
>>> Hello,
>>>
>>> I suspect that there are some problems while switching slaves manually on
>>> IPv6-only bonds. I have tested that this does not work on 2.6.18 kernel
>>> (RHEL5). I looked at recent sources (2.6.26) and even though there were
>>> multiple changes in bonding code, I still don't see how this could work.
>>>
>>> Testing setup
>>> -------------
>>>
>>> Two ethernets enslaved (eth2 and eh3), active-backup bond has IPv6-only
>>> address (no IPv4)
>>>
>>> Everything works fine, but if we switch the slave doing
>>>
>>> # ifenslave -c bond0 eth3
>>>
>>> the incoming ping6 to this host stops for up to several minutes (waiting
>>> until the switch updates its caches).
>> We _just_ put in an IPv6 fix, FWIW...
>>
> 
> Hi Jeff,
> 
> do you mean the patch for ALB/TLB bonds? I looked at it but I still don't 
> understand how this helps for active-backup case.

It doesn't.  What appears to happen in the active-backup case the MLD reports
are not generated on all of the slave devices, just the active one.  Thus the
switch knows only about the active device.

When you force the failover, no reports happen because the device believes that
the MLD group was already reported.  Thus there needs to be some trigger after
the failover to tell the switch that the mac address and multicast group have
moved to a different port.

-vlad
