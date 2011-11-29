From: David Miller <davem@davemloft.net>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 16:52:05 -0500 (EST)
Message-ID: <20111129.165205.91103035999089185.davem@davemloft.net>
References: <1322600212.2596.13.camel@edumazet-laptop>
	<CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
	<1322603175.2596.31.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ycheng@google.com, rick.jones2@hp.com, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:43879 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2VwV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:52:21 -0500
In-Reply-To: <1322603175.2596.31.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 29 Nov 2011 22:46:15 +0100

> Le mardi 29 novembre 2011 =E0 13:20 -0800, Yuchung Cheng a =E9crit :
>> I actually think it's a feature :)
>>=20
>> I find it awkward to set CC on listening socket. And current documen=
t
>> defines the sysctl well
>>=20
>> tcp_congestion_control - STRING
>>         Set the congestion control algorithm to be used for new
>>         connections. The algorithm "reno" is always available, but
>>         additional choices may be available based on kernel configur=
ation.
>>         Default is set as part of kernel configuration.
>=20
> This might be a feature, but contradicts most socket options set on
> listener and inherited by a child socket on accept()

There is really no reason to keep the current behavior.

If an application sets the congestion control algorithm on a listening
socket to a non-default value, what effect could possibly be intended?

Congestion control doesn't even come into play at all on a listening
socket, therefore the only logical expectation is that it inherits to
the child.

The only other logical behavior would be to forbid this operation on a
listening socket, since it has no effect, but that doesn't make any
sense now does it? :-)
