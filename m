From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] rtnl: Simplify ASSERT_RTNL
Date: Sat, 29 Sep 2007 11:18:18 -0600
Message-ID: <m13awx8k6d.fsf@ebiederm.dsl.xmission.com>
References: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ebiederm.dsl.xmission.com ([166.70.28.69]:51279 "EHLO
	ebiederm.dsl.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755081AbXI2RTo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Sep 2007 13:19:44 -0400
In-Reply-To: <E1IbTz0-0000FK-00@gondolin.me.apana.org.au> (Herbert Xu's
	message of "Sat, 29 Sep 2007 12:31:14 +0800")
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu <herbert@gondor.apana.org.au> writes:

> Eric W. Biederman <ebiederm@xmission.com> wrote:
>> 
>> Currently we have the call path:
>> macvlan_open -> dev_unicast_add -> __dev_set_rx_mode ->
>>        __dev_set_promiscuity -> ASSERT_RTNL -> mutex_trylock
>> 
>> When mutex debugging is on taking a mutex complains if we are not
>> allowed to sleep.  At that point we have called netif_tx_lock_bh
>> so we are clearly not allowed to sleep.  Arguably this is not a
>> problem for mutex_trylock.
>
> Actually holding the TX lock here is a bug.  We're going to
> call down into the hardware with __dev_set_promiscuity, which
> may sleep (think USB NICs), so we definitely shouldn't be holding
> any spin locks.

Regardless of the correctness of where we have ASSERT_RTNL.
I think not actually taking the mutex on the assertion failure path
(just so we can release it), is still a good deal regardless.

For this particular call site clearly we need to look at what
is happening a little more.  The obvious thing would be to add
an explicit might_sleep if we are calling code that can sleep.

Eric
