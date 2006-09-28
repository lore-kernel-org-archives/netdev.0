From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC][PATCH 1/3] enable bonding to enslave non ARPHRD_ETHER netdevices
Date: Thu, 28 Sep 2006 10:02:40 -0700
Message-ID: <200609281702.k8SH2eZt024937@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261316420.24189@zuben> <200609261923.k8QJNLZt021182@death.nxdomain.ibm.com> <15ddcffd0609271259o31cd0d20r9bfea4cf2ec979b4@mail.gmail.com>
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e36.co.us.ibm.com ([32.97.110.154]:43963 "EHLO
	e36.co.us.ibm.com") by vger.kernel.org with ESMTP id S1751940AbWI1RCq
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:02:46 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e36.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8SH2h4D019622
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 13:02:43 -0400
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8SH2hkC339574
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 11:02:43 -0600
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8SH2haD024445
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 11:02:43 -0600
To: "Or Gerlitz" <or.gerlitz@gmail.com>
In-reply-to: <15ddcffd0609271259o31cd0d20r9bfea4cf2ec979b4@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <or.gerlitz@gmail.com> wrote:

>On 9/26/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>> Or Gerlitz <ogerlitz@voltaire.com> wrote:
>> [...]
>> +       bond->dev->mtu              = new_active->dev->mtu;
>>
>>         This won't generate a NETDEV_CHANGEMTU notifier event.
>
>What is actually the trigger for the event with the current impl? is
>the code that actually calls dev_set_mtu() on the bonding device or
>dev_set_mtu() itself?

	My comment wasn't quite totally thought out; pretend you didn't
see it.

	I think what would be better overall is to handle the mtu for
this case the way bonding handles the mtu for other slave devices.
Normally, the mtu is pushed to the slaves from the bonding master, not
the other way around.  So, you don't want to assign the master's mtu
here; the slave mtu should already be up to date (and set to whatever
the master's mtu is via the usual mechanism, bond_change_mtu for
changes, or set in the slave at enslavement time).

[...]
>So at the bottom line, i would go on enhancing my patch not to allow
>bonding together devices of different types or at least if you don't
>mind, not to allow putting ARPHRD_INFINIBAND with
>non-ARPHRD_INFINIBAND devices in the same bond.

	I think this (disallowing bonding of dissimilar ARPHRD types) is
the way to go, at least in the short term.  Get it to work for the
common case first, then deal with the fringe stuff later.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
