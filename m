From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix array index in ip6_mc_add_src()
Date: Mon, 02 Apr 2012 16:19:50 -0400 (EDT)
Message-ID: <20120402.161950.1558486977364492163.davem@davemloft.net>
References: <1333269926-24681-1-git-send-email-roy.qing.li@gmail.com>
	<20120401.151318.984514868716173152.davem@davemloft.net>
	<CAJFZqHwAFao9En4LRBST3YSufbrjbtsV09_h9fOVTSsCHtsT_w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: roy.qing.li@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:54917 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751686Ab2DBUT4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Apr 2012 16:19:56 -0400
In-Reply-To: <CAJFZqHwAFao9En4LRBST3YSufbrjbtsV09_h9fOVTSsCHtsT_w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: RongQing Li <roy.qing.li@gmail.com>
Date: Mon, 2 Apr 2012 18:16:14 +0800

> 2012/4/2 David Miller <davem@davemloft.net>:
>> From: roy.qing.li@gmail.com
>> Date: Sun, =A01 Apr 2012 16:45:26 +0800
>>
>>> From: RongQing.Li <roy.qing.li@gmail.com>
>>>
>>> Convert array index from the loop bound to the loop index.
>>>
>>> Signed-off-by: RongQing.Li <roy.qing.li@gmail.com>
>>
>> That's not all you are doing:
>>
>>> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (void) ip6_mc_del1_src(pm=
c, sfmode, &psfsrc[i]);
>>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ip6_mc_del1_src(pmc, sfmo=
de, &psfsrc[j]);
>>
>> You absolutely MUST mention and explain this (void) removal.
>> It's probably there to elide an unchecked return value
>> warning from the compiler.
>=20
> since ip6_mc_del1_src() does not use __must_check likely attribute.
> I try to compile with several gcc warning options, but do not
> find which options can report the unchecked return value.

I said "probably", I didn't check myself.

The issue I had was that you didn't mention the void removal in the
commit message.
