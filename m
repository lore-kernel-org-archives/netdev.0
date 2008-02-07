From: Laszlo Attila Toth <panther@balabit.hu>
Subject: Re: [PATCH 1/2] Remove unnecessary locks from rtnetlink
Date: Thu, 07 Feb 2008 13:00:40 +0100
Message-ID: <47AAF2E8.30802@balabit.hu>
References: <12018820194128-git-send-email-panther@balabit.hu>	<12018820542721-git-send-email-panther@balabit.hu> <20080205.175337.266368079.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www.balabit.hu ([212.92.18.33]:41272 "EHLO lists.balabit.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754916AbYBGMAn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 7 Feb 2008 07:00:43 -0500
Received: from balabit.hu (unknown [10.80.0.254])
	by lists.balabit.hu (Postfix) with ESMTP id 39CA6C1537
	for <netdev@vger.kernel.org>; Thu,  7 Feb 2008 13:00:42 +0100 (CET)
In-Reply-To: <20080205.175337.266368079.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller =EDrta:
> From: Laszlo Attila Toth <panther@balabit.hu>
> Date: Fri,  1 Feb 2008 17:07:33 +0100
>=20
>> The do_setlink() function is protected by rtnl, additional locks are=
 unnecessary.
>> and the set_operstate() function is called from protected parts. Loc=
ks removed
>> from both functions.
>>
>> The set_operstate() is also called from rtnl_create_link() and from =
no other places.
>> In rtnl_create_link() none of the changes is protected by set_lock_b=
h() except
>> inside set_operstate(), different locking scheme is not necessary
>> for the operstate.
>>
>> Signed-off-by: Laszlo Attila Toth <panther@balabit.hu>
>=20
> The protection using dev_base_lock() is needed.
>=20
> When analyzing cases like this you need to also look at other code
> paths outside of rtnetlink that access ->operstate and ->link_mode,
> you obviously didn't do this.
>=20
> For example, net/core/net-sysfs.c takes a read lock on dev_base_lock
> in order to fetch a stable copy of both netif_running() and
> dev->operstate at the same time.
>=20
> Similar write locking to protect dev->operstate is made by
> net/core/link_watch.c:rfc2863_policy(), for the same reason rtnetlink
> has to make this locking.
>=20
> You therefore cannot remove it.

Thanks for your answer, yes, unfortunatelly I checked only inside=20
rtnetlink.c

--
Attila
