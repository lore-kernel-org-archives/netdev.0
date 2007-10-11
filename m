From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Thu, 11 Oct 2007 02:23:35 -0600
Message-ID: <m1hckyf4ag.fsf@ebiederm.dsl.xmission.com>
References: <m1r6ki9tib.fsf@ebiederm.dsl.xmission.com>
	<20071010.211654.85404234.davem@davemloft.net>
	<m1r6k2i1es.fsf@ebiederm.dsl.xmission.com>
	<20071011071224.GA15860@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	Patrick McHardy <kaber@trash.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:38814 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752848AbXJKIY5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 04:24:57 -0400
In-Reply-To: <20071011071224.GA15860@gondor.apana.org.au> (Herbert Xu's
	message of "Thu, 11 Oct 2007 15:12:24 +0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Thu, Oct 11, 2007 at 12:57:31AM -0600, Eric W. Biederman wrote:
>>
>> There was a practical suggestion by Herbert that ASSERT_RTNL have a
>> might_sleep() added.  That suggestion will currently result in
>> ASSERT_RTNL firing unnecessarily from the macvlan_open code path.
>
> As I've already said we should change the macvlan and core
> netdev code so that this doesn't happen in the first place.

Agreed.  Until that is done I am reluctant to add a warning
to ASSERT_RTNL.  Last I looked at that part of the thread
it looked like you and Patrick were making good progress
towards unraveling that, so I have no problem adding
an extra warning when we don't expect it to ever trigger.

> In gernal checking for the RTNL while holding a spin lock is
> a sign of a bug.
>
> So I would object to a patch that caused the RTNL_ASSERT to not
> warn about being called in an atomic context.

ASSERT_RTNL does not warn about being called in an atomic context
today!

> I don't have a problem with your patch per se, it's the fact
> that the patch is removing the warning when it's called in an
> atomic context that I don't like.

No my patch does not remove a warning.

Way way deep in mutex debugging on the slowpath there is a unreadable
and incomprehensible WARN_ON in muxtex_trylock that will trigger if
you have 10 tons of debugging turned on, and you are in,
interrupt context, and you manage to hit the slow path.  I think that
is a pretty unlikely scenario.

Eric
