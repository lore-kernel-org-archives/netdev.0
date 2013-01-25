From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch net-next V2] bond: have random dev address by default instead of zeroes
Date: Fri, 25 Jan 2013 09:53:07 -0800
Message-ID: <21365.1359136387@death.nxdomain>
References: <1359057684-6732-1-git-send-email-jiri@resnulli.us> <13906.1359077701@death.nxdomain> <20130125063713.GA1659@minipsycho.orion> <20130125072221.GB1659@minipsycho.orion>
Cc: netdev@vger.kernel.org, davem@davemloft.net, andy@greyhouse.net,
	stephen@networkplumber.org, psimerda@redhat.com, dcbw@redhat.com
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e9.ny.us.ibm.com ([32.97.182.139]:49668 "EHLO e9.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756161Ab3AYRxQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Jan 2013 12:53:16 -0500
Received: from /spool/local
	by e9.ny.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Fri, 25 Jan 2013 12:53:15 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by d01dlp02.pok.ibm.com (Postfix) with ESMTP id AAD8D6E8041
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 12:53:10 -0500 (EST)
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id r0PHrBCu062540
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 12:53:11 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id r0PHr93u009017
	for <netdev@vger.kernel.org>; Fri, 25 Jan 2013 12:53:11 -0500
In-reply-to: <20130125072221.GB1659@minipsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jiri@resnulli.us> wrote:

>Fri, Jan 25, 2013 at 07:37:13AM CET, jiri@resnulli.us wrote:
>>Fri, Jan 25, 2013 at 02:35:01AM CET, fubar@us.ibm.com wrote:
>>>Jiri Pirko <jiri@resnulli.us> wrote:
>>>
>>>>Makes more sense to have randomly generated address by default than to
>>>>have all zeroes. It also allows user to for example put the bond into
>>>>bridge without need to have any slaves in it.
>>>>
>>>>Also note that this changes only behaviour of bonds with no slaves. Once
>>>>the first slave device is enslaved, its address will be used (no change
>>>>here).
>
>
>Also, this is not entirely true now. Example:
>
>eth1 has 52:54:00:b8:30:0b
>
># ip link add bondx address 22:33:44:55:66:77 type bond
># ip link set eth1 master bondx
>
>Now both bondx and eth1 has 22:33:44:55:66:77
>
>Shouldn't both have 52:54:00:b8:30:0b ?

	This is the way bonding has worked for as long as I can recall.
The MAC of the first slave is assigned to the master, unless the bond
has had its MAC manually set to something prior to the first slave being
added.  If the bond's MAC has been set manually, then that MAC is used
instead of the first slave's MAC.

	Your patch doesn't appear to change that behavior, but it does
substitute a random MAC in place of the all zeroes MAC used previously
(and tests a flag to determine if the MAC has been manually set instead
of checking for the all zeroes MAC).

	I know of customers that rely on this behavior to explicitly set
the MAC of the bond (for filtering or accounting purposes).  It probably
should be documented more clearly, but I don't think it should be
changed.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
