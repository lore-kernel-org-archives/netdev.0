From: David Miller <davem@davemloft.net>
Subject: Re: iproute uses too small of a receive buffer
Date: Wed, 28 Oct 2009 00:55:59 -0700 (PDT)
Message-ID: <20091028.005559.92092291.davem@davemloft.net>
References: <4AE77F64.3090302@candelatech.com>
	<20091027162434.6dc31b2d@nehalam>
	<4AE7F859.7020105@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: shemminger@vyatta.com, greearb@candelatech.com,
	netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:34671
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932611AbZJ1Hzf convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Oct 2009 03:55:35 -0400
In-Reply-To: <4AE7F859.7020105@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 28 Oct 2009 08:52:57 +0100

> Stephen Hemminger a =E9crit :
>>=20
>> Just having larger buffer isn't guarantee of success. Allocating
>> a huge buffer is not going to work on embedded.
>>=20
>=20
> Please note we do not allocate a big buffer, only allow more small sk=
bs
> to be queued on socket receive queue.
>=20
> If memory is not available, skb allocation will eventually fail
> and be reported as well, embedded or not.
>=20
> I vote for allowing 1024*1024 bytes instead of 32768,
> and eventually user should be warned that it is capped by=20
> /proc/sys/net/core/rmem_max

This discussion constantly reminds me of:

/*
 *	skb should fit one page. This choice is good for headerless malloc.
 *	But we should limit to 8K so that userspace does not have to
 *	use enormous buffer sizes on recvmsg() calls just to avoid
 *	MSG_TRUNC when PAGE_SIZE is very large.
 */
#if PAGE_SIZE < 8192UL
#define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(PAGE_SIZE)
#else
#define NLMSG_GOODSIZE	SKB_WITH_OVERHEAD(8192UL)
#endif

#define NLMSG_DEFAULT_SIZE (NLMSG_GOODSIZE - NLMSG_HDRLEN)
