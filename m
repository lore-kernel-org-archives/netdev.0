From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups
Date: Tue, 28 Apr 2009 16:58:36 +0200
Message-ID: <49F7199C.6080700@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com>	<49F3308B.1030507@cosmosbay.com>	<20090426.020411.157511269.davem@davemloft.net>	<49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56565 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758719AbZD1O7l convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Apr 2009 10:59:41 -0400
In-Reply-To: <87ab60rh8t.fsf@basil.nowhere.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
> Eric Dumazet <dada1@cosmosbay.com> writes:
>> When scheduled, thread does a full scan of all polled fds and
>> can sleep again, because nothing is really available. If number
>> of fds is large, this cause significant load.
>=20
> I wonder if the key could be used for more state. For example if you
> two processes are in recvmsg() on a socket and there's only a single
> packet incoming we only need to wake up the first waiter.  Could that
> be done with keys too?

I am not sure its possible. I'll take a look.

>=20
>> This patch makes select()/poll() aware of keyed wakeups and
>> useless wakeups are avoided. This reduces number of context
>> switches by about 50% on some setups, and work performed
>> by sofirq handlers.
>=20
> I'm late, but: very cool patch too.
>=20
> Acked-by: Andi Kleen <ak@linux.intel.com>

Thanks, I am going to send it again on lkml this time :)

