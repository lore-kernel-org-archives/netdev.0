From: Brian Haley <brian.haley@hp.com>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 14:33:54 -0400
Message-ID: <4846E012.9020300@hp.com>
References: <4845EDB0.7030809@hp.com>	<4845FDA1.1040009@cn.fujitsu.com>	<20080604.113751.123223388.yoshfuji@linux-ipv6.org> <20080604.120250.131119978.yoshfuji@linux-ipv6.org> <48460DDC.4040703@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: =?ISO-2022-JP?B?WU9TSElGVUpJIEhpZGVha2kgLyAbJEI1SEYjMVFMQBsoQg==?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Shan Wei <shanwei@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0014.houston.hp.com ([15.201.24.17]:18890 "EHLO
	g4t0014.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752537AbYFDSd5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Jun 2008 14:33:57 -0400
In-Reply-To: <48460DDC.4040703@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Shan Wei wrote:
>> +			if (addr_type != IPV6_ADDR_ANY) {
>> +				if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
>> +						   addr_type & IPV6_ADDR_LINKLOCAL ? dev : NULL, 0))
>>
> if ipi6_ifindex==2(eth0) and the ipi6_addr is loopback addr or multicast addr,
> ipv6_chk_addr() will return ture.

Won't ipv6_chk_addr() fail if given a multicast address since it's
looking in inet6_addr_lst[]?

Anyways, I've created a little chart showing the before/after
differences based on Yoshifuji's latest patch:

Behavior today:

src/ifindex	result
-----------	------

::/0		SUCCESS (packet sent on lo)
::/1 (lo)	SUCCESS (packet sent on lo)
::/3 (eth0)	SUCCESS (packet sent on lo)
::/27		SUCCESS (packet sent on lo)

::1/0		SUCCESS (packet sent on lo)
::1/1 (lo)	SUCCESS (packet sent on lo)
::1/3 (eth0)	SUCCESS (packet sent on lo)
::1/27		SUCCESS (packet sent on lo)

ff02::1/0	EINVAL
ff02::1/1	EINVAL
ff02::1/3	EINVAL
ff02::1/27	ENODEV


With patch, differences shown with **:

src/ifindex	result
-----------	------

::/0		SUCCESS (packet sent on lo)
::/1 (lo)	SUCCESS (packet sent on lo)
::/3 (eth0)	SUCCESS (packet sent on lo)
::/27		ENODEV **

::1/0		SUCCESS (packet sent on lo)
::1/1 (lo)	SUCCESS (packet sent on lo)
::1/3 (eth0)	EINVAL **
::1/27		ENODEV **

ff02::1/0	EINVAL
ff02::1/1	EINVAL
ff02::1/3	EINVAL
ff02::1/27	ENODEV


Is that change good with you?

-Brian

