From: Brian Haley <brian.haley@hp.com>
Subject: Re: 2.6.29 regression? Bonding tied to IPV6 in 29-rc5
Date: Tue, 17 Feb 2009 15:10:23 -0500
Message-ID: <499B19AF.1000003@hp.com>
References: <alpine.LFD.2.00.0902131413120.3179@localhost.localdomain> <20090217095232.5da06b9f@werewolf.home> <200902172001.41804.arvidjaar@mail.ru> <200902172117.22671.arvidjaar@mail.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw@sisk.pl>, netdev@vger.kernel.org,
	bonding-devel@lists.sourceforge.net,
	=?ISO-8859-1?Q?=22J=2EA=2E_Magall?= =?ISO-8859-1?Q?=F3n=22?=
	<jamagallon@ono.com>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>
To: Andrey Borzenkov <arvidjaar@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0028.austin.hp.com ([15.216.28.35]:15507 "EHLO
	g1t0028.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753429AbZBQUK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Feb 2009 15:10:28 -0500
In-Reply-To: <200902172117.22671.arvidjaar@mail.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andrey Borzenkov wrote:
> On 17 of February 2009 20:01:38 Andrey Borzenkov wrote:
>> Forward to bonding and netdev
>>
>> On 17 of February 2009 11:52:32 J.A. Magall=F3n wrote:
>>> Hi all...
>>>
>>> Don't know if this is specific for -rc5, I have jumped from 28.4 to
>>> 29-rc5. In this latest kernel, I can not install 'bonding' module
>>> if 'ipv6' is disabled to load via modprobe.conf:
>>>
>>> install ipv6 /bin/true
>>>
>>> Trying bonding gives this dmesg:
>>>
>>> bonding: Unknown symbol ndisc_build_skb
>>> bonding: Unknown symbol in6_dev_finish_destroy
>>> bonding: Unknown symbol ndisc_send_skb
>>> bonding: Unknown symbol unregister_inet6addr_notifier
>>> bonding: Unknown symbol register_inet6addr_notifier
>>>
>>> Commenting the line in modprobe.conf makes things smooth again.
>>> We can not disable ipv6 anymore ?
>> If IPv6 is disable in kernel config bonding loads. But I think it is
>> regression, it should be possible to disable IPv6 if not required.
>=20
> This hard dependency was apparently introduced by this commit:
>=20
> commit 305d552accae6afb859c493ebc7d98ca3371dae2
> Author: Brian Haley <brian.haley@hp.com>
> Date:   Tue Nov 4 17:51:14 2008 -0800
>=20
>     bonding: send IPv6 neighbor advertisement on failover

I initially had bonding IPv6 support as a Kconfig option, but it was=20
decided it would be cleaner if it just got built-in whenever CONFIG_IPV=
6=20
was set like SCTP, with the assumption you might want it.

Is it a common configuration to not allow a module to load like you're=20
doing in modprobe.conf?  I don't know how hard it would be to rip this=20
out into it's own bonding_ipv6.ko module, simply turning-off CONFIG_IPV=
6=20
seems better.

-Brian
