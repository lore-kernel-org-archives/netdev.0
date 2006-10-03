From: Or Gerlitz <ogerlitz@voltaire.com>
Subject: Re: [RFC] [PATCH 3/3] enable IP multicast when bonding IPoIB devices
Date: Tue, 03 Oct 2006 15:06:38 +0200
Message-ID: <4522605E.8000208@voltaire.com>
References: <Pine.LNX.4.64.0609261309540.24189@zuben> <Pine.LNX.4.64.0609261317460.24189@zuben> <200609262340.k8QNeVZt030301@death.nxdomain.ibm.com> <15ddcffd0609271312m3a4f9613ke3d81695684ca523@mail.gmail.com> <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Roland Dreier <rdreier@cisco.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from taurus.voltaire.com ([193.47.165.240]:50359 "EHLO
	taurus.voltaire.com") by vger.kernel.org with ESMTP id S932156AbWJCNGp
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 09:06:45 -0400
To: Jay Vosburgh <fubar@us.ibm.com>
In-Reply-To: <200609281743.k8SHhoZt014879@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jay Vosburgh wrote:
> Or Gerlitz <or.gerlitz@gmail.com> wrote:
> 
>> On 9/27/06, Jay Vosburgh <fubar@us.ibm.com> wrote:
>>> Or Gerlitz <ogerlitz@voltaire.com> wrote:
> [...]
>>>         You almost want to have some kind of call to induce a reload
>>> from scratch of the multicast filter settings (along with whatever else
>>> might be necessary to alter the hardware type on the fly), to be called
>>> by bonding at the time the first slave is added (since slave adds happen
>>> in user context, and can therefore hold rtnl as required by most of the
>>> multicast address handling code).  That seems less hassle than having to
>>> specify the hardware type and address length at module load time.
>> I agree that it would be better to avoid doing it this way.
> 
> 	Actually, it would be ideal to do it this way in all cases, as
> the change of hardware type is the biggest hurdle to cross-hardware
> bonding instances.  The current infrastructure simply won't allow it,
> though, since bonding failover events usually occur in a timer context
> (if memory serves, timers run in softirq and can't acquire rtnl).

Sorry, but I don't follow... by saying "would be ideal to do ***it*** 
this way in all cases" what exactly is the "it" you are referring to?

> 
> [...]
>>>         Other random thoughts on how to resolve this include modifying
>>> bonding to accept slaves when the master is down (which would also
>>> require changes to the initscripts that normally configure bonding), so
>>> that the initial setting of the, e.g., 224.0.0.1 multicast hardware
>>> address happens to the already-changed hardware type.
>> OK, this is a direction i would like to check. Can be nice if you
>> provide me with a 1-2 liner of directions on what need to be changed
>> to enable bonding to accept slaves when it down.
> 
> 	I don't think right offhand this would be a particularly
> difficult change; the "up" operation for bonding mostly just starts up
> various timers.  A few minutes poking around doesn't reveal anything
> obvious that would hinder enslaving with the master down.  You'll have
> to change ifenslave and the sysfs code to allow enslaves with the master
> down; that might be all that's needed for bonding itself.  Changing
> /sbin/ifup and friends is a separate problem.

OK, lets see i follow:

1st, your current recommendation to solve the link layer address 
computation of multicast groups joined by the stack before any 
enslavement actually takes place, is to instrument the bonding code such 
that it would be possible to enslave devices when the bonding device is 
not "up" yet.

2nd, the change need to be worked out in the bonding sysfs code, the 
ifenslave program but ***also*** in packages such as /sbin/ifup and friends.

???

BTW - is the ifenslave program still supported to work with upstream 
(2.6.18 and above) kernel or it was obsoleted at some point.

Or.

