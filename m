From: Ying Xue <ying.xue@windriver.com>
Subject: Re: [PATCH net-next 1/5] tipc: silence sparse warnings
Date: Fri, 27 Sep 2013 16:01:21 +0800
Message-ID: <52453B51.5070702@windriver.com>
References: <1380014868-2797-1-git-send-email-jon.maloy@ericsson.com> <1380014868-2797-2-git-send-email-jon.maloy@ericsson.com> <20130927.015908.1293107524454870319.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <jon.maloy@ericsson.com>, <netdev@vger.kernel.org>,
	<paul.gortmaker@windriver.com>, <erik.hugne@ericsson.com>,
	<maloy@donjonn.com>, <tipc-discussion@lists.sourceforge.net>,
	<andreas.bofjall@ericsson.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:46513 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750852Ab3I0IBl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Sep 2013 04:01:41 -0400
In-Reply-To: <20130927.015908.1293107524454870319.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/27/2013 01:59 PM, David Miller wrote:
> From: Jon Maloy <jon.maloy@ericsson.com>
> Date: Tue, 24 Sep 2013 04:27:44 -0500
>=20
>> From: Ying Xue <ying.xue@windriver.com>
>>
>> Eliminate below sparse warnings:
>>
>> net/tipc/link.c:1210:37: warning: cast removes address space of expr=
ession
>> net/tipc/link.c:1218:59: warning: incorrect type in argument 2 (diff=
erent address spaces)
>> net/tipc/link.c:1218:59:    expected void const [noderef] <asn:1>*fr=
om
>> net/tipc/link.c:1218:59:    got unsigned char const [usertype] *[ass=
igned] sect_crs
>> net/tipc/msg.c:96:61: warning: incorrect type in argument 3 (differe=
nt address spaces)
>> net/tipc/msg.c:96:61:    expected void const *from
>> net/tipc/msg.c:96:61:    got void [noderef] <asn:1>*const iov_base
>> net/tipc/socket.c:341:49: warning: Using plain integer as NULL point=
er
>> net/tipc/socket.c:1371:36: warning: Using plain integer as NULL poin=
ter
>> net/tipc/socket.c:1694:57: warning: Using plain integer as NULL poin=
ter
>>
>> Signed-off-by: Ying Xue <ying.xue@windriver.com>
>> Signed-off-by: Andreas Bofj=E4ll <andreas.bofjall@ericsson.com>
>> Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
>> Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
>=20
> These warnings are not just for fun, and they are certainly not an
> invitation to stick casts all over the place to make them go away.
>=20
> They indicate real problems in the TIPC code.
>=20
> There really are user pointers in the iovecs here, and that's why the
> iov_base member is annotated with "__user".
>=20
> These iovecs carry pointers that come from userspace via socket calls=
=2E
>=20
> And you absolutely cannot pass user pointers to skb_copy_to_linear_da=
ta()
> and friends as they access the source pointer using memcpy().
>=20

Good point!
It's better for us to use memcpy_fromiovecend() instead of
skb_copy_to_linear_data() and its friends.

We will submit another version to correct this error soon.

Regards,
Ying

> You have to use the proper interfaces for accessing userspace memory,
> ones that have their arguments annotated with __user.
>=20
> I'm not applying this series, sorry.
>=20
>=20
