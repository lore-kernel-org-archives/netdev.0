From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Thu, 28 Sep 2006 10:43:50 -0700
Message-ID: <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com>
Cc: "Or Gerlitz" <ogerlitz@voltaire.com>, netdev@vger.kernel.org,
	"Roland Dreier" <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:36784 "EHLO
	e33.co.us.ibm.com") by vger.kernel.org with ESMTP id S1030314AbWI1Rny
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 28 Sep 2006 13:43:54 -0400
Received: from d03relay04.boulder.ibm.com (d03relay04.boulder.ibm.com [9.17.195.106])
	by e33.co.us.ibm.com (8.13.8/8.12.11) with ESMTP id k8SHhrQ5030686
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 13:43:53 -0400
Received: from d03av01.boulder.ibm.com (d03av01.boulder.ibm.com [9.17.195.167])
	by d03relay04.boulder.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k8SHhr1X033312
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 11:43:53 -0600
Received: from d03av01.boulder.ibm.com (loopback [127.0.0.1])
	by d03av01.boulder.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k8SHhqB9012019
	for <netdev@vger.kernel.org>; Thu, 28 Sep 2006 11:43:53 -0600
To: "Or Gerlitz" <or.gerlitz@gmail.com>
In-reply-to: <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> 
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Or Gerlitz <or.gerlitz@gmail.com> wrote:

>On 9/27/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>> Or Gerlitz <ogerlitz@voltaire.com> wrote:
[...]
>>         You almost want to have some kind of call to induce a reload
>> from scratch of the multicast filter settings (along with whatever else
>> might be necessary to alter the hardware type on the fly), to be called
>> by bonding at the time the first slave is added (since slave adds happen
>> in user context, and can therefore hold rtnl as required by most of the
>> multicast address handling code).  That seems less hassle than having to
>> specify the hardware type and address length at module load time.
>
>I agree that it would be better to avoid doing it this way.

	Actually, it would be ideal to do it this way in all cases, as
the change of hardware type is the biggest hurdle to cross-hardware
bonding instances.  The current infrastructure simply won't allow it,
though, since bonding failover events usually occur in a timer context
(if memory serves, timers run in softirq and can't acquire rtnl).

[...]
>>         Other random thoughts on how to resolve this include modifying
>> bonding to accept slaves when the master is down (which would also
>> require changes to the initscripts that normally configure bonding), so
>> that the initial setting of the, e.g., 224.0.0.1 multicast hardware
>> address happens to the already-changed hardware type.
>
>OK, this is a direction i would like to check. Can be nice if you
>provide me with a 1-2 liner of directions on what need to be changed
>to enable bonding to accept slaves when it down.

	I don't think right offhand this would be a particularly
difficult change; the "up" operation for bonding mostly just starts up
various timers.  A few minutes poking around doesn't reveal anything
obvious that would hinder enslaving with the master down.  You'll have
to change ifenslave and the sysfs code to allow enslaves with the master
down; that might be all that's needed for bonding itself.  Changing
/sbin/ifup and friends is a separate problem.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
