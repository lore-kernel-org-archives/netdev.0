From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/5] tipc: silence sparse warnings
Date: Fri, 27 Sep 2013 01:59:08 -0400 (EDT)
Message-ID: <20130927.015908.1293107524454870319.davem@davemloft.net>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com>
	<1380014868-2797-2-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, paul.gortmaker@windriver.com,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net, andreas.bofjall@ericsson.com
To: jon.maloy@ericsson.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:50225 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751171Ab3I0F7N convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 01:59:13 -0400
In-Reply-To: <1380014868-2797-2-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Jon Maloy <jon.maloy@ericsson.com>
Date: Tue, 24 Sep 2013 04:27:44 -0500

> From: Ying Xue <ying.xue@windriver.com>
>=20
> Eliminate below sparse warnings:
>=20
> net/tipc/link.c:1210:37: warning: cast removes address space of expre=
ssion
> net/tipc/link.c:1218:59: warning: incorrect type in argument 2 (diffe=
rent address spaces)
> net/tipc/link.c:1218:59:    expected void const [noderef] <asn:1>*fro=
m
> net/tipc/link.c:1218:59:    got unsigned char const [usertype] *[assi=
gned] sect_crs
> net/tipc/msg.c:96:61: warning: incorrect type in argument 3 (differen=
t address spaces)
> net/tipc/msg.c:96:61:    expected void const *from
> net/tipc/msg.c:96:61:    got void [noderef] <asn:1>*const iov_base
> net/tipc/socket.c:341:49: warning: Using plain integer as NULL pointe=
r
> net/tipc/socket.c:1371:36: warning: Using plain integer as NULL point=
er
> net/tipc/socket.c:1694:57: warning: Using plain integer as NULL point=
er
>=20
> Signed-off-by: Ying Xue <ying.xue@windriver.com>
> Signed-off-by: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
> Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>

These warnings are not just for fun, and they are certainly not an
invitation to stick casts all over the place to make them go away.

They indicate real problems in the TIPC code.

There really are user pointers in the iovecs here, and that's why the
iov_base member is annotated with "__user".

These iovecs carry pointers that come from userspace via socket calls.

And you absolutely cannot pass user pointers to skb_copy_to_linear_data=
()
and friends as they access the source pointer using memcpy().

You have to use the proper interfaces for accessing userspace memory,
ones that have their arguments annotated with __user.

I'm not applying this series, sorry.
