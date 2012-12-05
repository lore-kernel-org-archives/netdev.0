From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 0/7] Allow to monitor multicast cache event
 via rtnetlink
Date: Wed, 05 Dec 2012 12:53:26 -0500 (EST)
Message-ID: <20121205.125326.1946963285042434825.davem@davemloft.net>
References: <20121204.130914.1457976839967676240.davem@davemloft.net>
	<50BE56D3.2030704@6wind.com>
	<50BF29DA.7020903@6wind.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:35408 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752065Ab2LERx1 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Dec 2012 12:53:27 -0500
In-Reply-To: <50BF29DA.7020903@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Date: Wed, 05 Dec 2012 12:02:50 +0100

> Le 04/12/2012 21:02, Nicolas Dichtel a =E9crit :
>> I can have a try on a tile platform. I don't have access to sparc or
>> mips.
> Hmm, I've read arm instead of mips! So I've tried on mips. Data are
> aligned on 32-bit, like for all netlink messages. nla_put_u64() will
> do the same, as it calls nla_put().
>=20
> And the kernel will only use memcpy() to treat this attribute. Reader
> will be in userland.

Then userland will trap if the 64-bit values are only 32-bit aligned.

That's the problem I'm talking about.

I don't want to export any more unaligned 64-bit values in netlink
messages, it's a complete mess.
