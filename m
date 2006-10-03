From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC][PATCH 1/3] enable bonding to enslave non ARPHRD_ETHER netdevices
Date: Tue, 03 Oct 2006 14:56:20 +0200
Message-ID: <45225DF4.4070503@voltaire.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261316420.24189@zuben> <200609261923.k8QJNLZt021182@death.nxdomain.ibm.com> <15ddcffd0609271259o31cd0d20r9bfea4cf2ec979b4@mail.gmail.com> <200609281702.k8SH2eZt024937@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:17334 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S932101AbWJCM4d
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 08:56:33 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609281702.k8SH2eZt024937@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <or.gerlitz@gmail.com> wrote:
> 
>> On 9/26/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>>> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>>> [...]
>>> +       bond->dev->mtu              = new_active->dev->mtu;
>>>
>>>         This won't generate a NETDEV_CHANGEMTU notifier event.

>> What is actually the trigger for the event with the current impl? is
>> the code that actually calls dev_set_mtu() on the bonding device or
>> dev_set_mtu() itself?

> 	My comment wasn't quite totally thought out; pretend you didn't
> see it.

> 	I think what would be better overall is to handle the mtu for
> this case the way bonding handles the mtu for other slave devices.
> Normally, the mtu is pushed to the slaves from the bonding master, not
> the other way around.  So, you don't want to assign the master's mtu
> here; the slave mtu should already be up to date (and set to whatever
> the master's mtu is via the usual mechanism, bond_change_mtu for
> changes, or set in the slave at enslavement time).

OK, i think i got you. Today the dev_set_mtu() is called on the slave 
device only when someone attempts to change the bond MTU. So you suggest 
to do it also during enslavement so the current master MTU would be 
propagated to the slaves and not vise versa, this makes sense.

> [...]
>> So at the bottom line, i would go on enhancing my patch not to allow
>> bonding together devices of different types or at least if you don't
>> mind, not to allow putting ARPHRD_INFINIBAND with
>> non-ARPHRD_INFINIBAND devices in the same bond.
> 
> 	I think this (disallowing bonding of dissimilar ARPHRD types) is
> the way to go, at least in the short term.  Get it to work for the
> common case first, then deal with the fringe stuff later.

OK, as you are fine with it, i will modify the patch to disallow bonding 
of dissimilar ARPHRD types.

Or.

