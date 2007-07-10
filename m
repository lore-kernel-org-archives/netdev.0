From: Patrick McHardy <kaber@trash.net>
Subject: Re: + gen_estimator-fix-locking-and-timer-related-bugs.patch added
 to -mm tree
Date: Tue, 10 Jul 2007 14:20:12 +0200
Message-ID: <4693797C.1020408@trash.net>
References: <1183727654.6389.3.camel@ranko-fc2.spidernet.net> <468E4FD9.4060702@trash.net> <1183733732.6389.26.camel@ranko-fc2.spidernet.net> <1183794918.30237.69.camel@localhost.localdomain> <Pine.LNX.4.64.0707071704370.1808@x2> <1183984861.18656.21.camel@ranko-fc2.spidernet.net> <46923DA8.9010208@trash.net> <1183999420.18656.54.camel@ranko-fc2.spidernet.net> <20070710073447.GA1870@ff.dom.local> <1184062147.11966.37.camel@localhost.localdomain> <20070710121756.GB3130@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: Ranko Zivojnovic <ranko@spidernet.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@o2.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:58247 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751662AbXGJMUa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jul 2007 08:20:30 -0400
In-Reply-To: <20070710121756.GB3130@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Jarek Poplawski wrote:
> On Tue, Jul 10, 2007 at 01:09:07PM +0300, Ranko Zivojnovic wrote:
> 
>>However I decided not to use _rcu based iteration neither the
>>rcu_read_lock() after going through the RCU documentation and a bunch of
>>examples in kernel that iterate through the lists using non _rcu macros
>>and do list_del_rcu() just fine.
>>
>>For readability, the reference to list_del_rcu as well as call_rcu, I
>>believe, should be enough of the indication. Please do correct me if I
>>am wrong here.
> 
> 
> It's only my opinion, and it's probably not very popular at least
> at net/ code, so it's more about general policy and not this
> particular code. But:
> - if somebody is looking after some rcu related problems, why can't
> he/she spare some time by omitting lists without _rcu and not
> analyzing why/how such lists are used and locked?


RCU is used for the read-side, using it on the write-side just makes
things *less* understandable IMO. It will look like the read-side
but still do modifications.

