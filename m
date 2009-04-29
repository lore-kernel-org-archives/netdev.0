From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [PATCH] poll: Avoid extra wakeups in select/poll
Date: Wed, 29 Apr 2009 09:37:42 +0200
Message-ID: <49F803C6.5070006@cosmosbay.com>
References: <alpine.DEB.1.10.0904241554100.29995@qirst.com> <49F3308B.1030507@cosmosbay.com> <20090426.020411.157511269.davem@davemloft.net> <49F43B8F.2050907@cosmosbay.com> <87ab60rh8t.fsf@basil.nowhere.org> <49F71B63.8010503@cosmosbay.com> <20090429002049.4bbc8105.akpm@linux-foundation.org> <20090429073539.GR27382@one.firstfloor.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	linux kernel <linux-kernel@vger.kernel.org>,
	David Miller <davem@davemloft.net>, cl@linux.com,
	jesse.brandeburg@intel.com, netdev@vger.kernel.org,
	haoki@redhat.com, mchan@broadcom.com, davidel@xmailserver.org,
	Ingo Molnar <mingo@elte.hu>
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:45973 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751019AbZD2HkY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Apr 2009 03:40:24 -0400
In-Reply-To: <20090429073539.GR27382@one.firstfloor.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andi Kleen a =E9crit :
>> Seems that this is a virtuous patch even though Christoph is struggl=
ing
>> a bit to test it?
>=20
> The main drawback is that the select/poll data structures will get
> larger. That could cause regression in theory. But I suspect
> the win in some situations is still worth it. Of course
> it would be nice if it handled more situations (like
> multiple reader etc.)

On poll()/select() interface, we must wakeup every pollers, because we =
dont know
if they really will consume the event

thread 1:
poll();
<insert an exit() or something bad here>
read();

thread 2:
poll(); /* no return because event was 'granted' to thread 1 */
read();


We could try to optimize read()/recvfrom() because we can know if event
is consumed, as its a whole syscall.


