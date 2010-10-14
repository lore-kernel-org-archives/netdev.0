From: David Miller <davem@davemloft.net>
Subject: Re: BUG ? ipip unregister_netdevice_many()
Date: Wed, 13 Oct 2010 21:50:13 -0700 (PDT)
Message-ID: <20101013.215013.104074480.davem@davemloft.net>
References: <m11v801tfr.fsf@fess.ebiederm.org>
	<20101012.130520.48517464.davem@davemloft.net>
	<m1fww94ca6.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hans.schillstrom@ericsson.com, daniel.lezcano@free.fr,
	netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:47672
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754627Ab0JNEtv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Oct 2010 00:49:51 -0400
In-Reply-To: <m1fww94ca6.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Wed, 13 Oct 2010 21:40:49 -0700

> However I think the test should still be rt_is_expired(), because
> that is what rt_do_flush() is doing removing the expired entries
> from the list.

I can't see a reason for that test.

Everything calling into this code path has created a condition
that requires that all routing cache entries for that namespace
be deleted.

This function is meant to unconditionally flush the entire table.

I believe you added that extraneous test, and it never existed there
before.
