From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [patch for 2.6.24? 1/1] bonding: locking fix
Date: Fri, 18 Jan 2008 09:32:44 -0800
Message-ID: <10345.1200677564@death>
References: <200801140904.m0E94vJd020425@imap1.linux-foundation.org> <Pine.LNX.4.64.0801142313350.26034@bizon.gios.gov.pl> <20080114144754.29a448ad.akpm@linux-foundation.org> <16796.1200351673@death> <20080117154243.9ee4265c.akpm@linux-foundation.org> <24607.1200616005@death> <Pine.LNX.4.64.0801180154570.4570@bizon.gios.gov.pl> <27063.1200620733@death> <Pine.LNX.4.64.0801180932440.4570@bizon.gios.gov.pl>
Cc: Andrew Morton <akpm@linux-foundation.org>, davem@davemloft.net,
	jeff@garzik.org, shemminger@linux-foundation.org,
	netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>
To: Krzysztof Oledzki <olel@ans.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:37206 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1761912AbYARRdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 18 Jan 2008 12:33:35 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e3.ny.us.ibm.com (8.13.8/8.13.8) with ESMTP id m0IHWlri014015
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 12:32:47 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay02.pok.ibm.com (8.13.8/8.13.8/NCO v8.7) with ESMTP id m0IHWlJ4079762
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 12:32:47 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id m0IHWk60017882
	for <netdev@vger.kernel.org>; Fri, 18 Jan 2008 12:32:47 -0500
In-reply-to: <Pine.LNX.4.64.0801180932440.4570@bizon.gios.gov.pl> 
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Krzysztof Oledzki <olel@ans.pl> wrote:
[...]
>> 	which makes the warning go away, but Herbert Xu pointed out that
>> there is a potential problem with bond_enslave accessing the mc_lists
>> without sufficient locking.  It's not the only offender, either, and the
>> bond->mc_list references really need to be protected by the bond_lock,
>> and the whole thing probably ought to use dev_mc_sync/unsync instead of
>> what it does now.
>>
>> 	Since the bond_enslave, et al, business isn't a new problem, and
>> I've never heard of it being hit, I'm thinking now to just leave the
>> bond_enslave part for 2.6.25, and fix the lockdep warning for 2.6.24.
>
>It is a new problem, as it never happened with <=2.6.23.

	The lockdep warning is new, but I was referring to the lack of
mutexing between bond_enslave, bond_release, etc and the
set_multicast_list's use of the mc_lists.  There has never been mutexing
of the mc_lists in bond_enslave & friends, so that is not a new problem.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
