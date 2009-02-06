From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
Subject: Re: [PATCH] netns: remove useless synchronize_net()
Date: Fri, 06 Feb 2009 14:50:53 +0100
Message-ID: <498C403D.9040500@dev.6wind.com>
References: <498ABDA2.5040603@dev.6wind.com> <20090205.234520.149982266.davem@davemloft.net>
Reply-To: nicolas.dichtel@dev.6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:33888 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753180AbZBFNvG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 08:51:06 -0500
In-Reply-To: <20090205.234520.149982266.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 06.02.2009 08:45, David Miller a =E9crit :
> From: Nicolas Dichtel <nicolas.dichtel@dev.6wind.com>
> Date: Thu, 05 Feb 2009 11:21:22 +0100
>=20
>> In dev_change_net_namespace(), synchronize_net() is called at the
>> end of the function, but there is no reason (no deletion occurs).
>>
>> Signed-off-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
>=20
> It is necessary to make sure all cpus stop looking at the
> previous namespace the device was attached to, and only
> see the new mapping.
I didn't really understand why it is 'necessary'.
If namespace is destroyed after this function, then cleanup_net() will =
ensure=20
that nobody is looking at it
There is only two callers, rtnetlink and default_device_exit().


Thank you for your answer,
Nicolas

>=20
> That's why this function has two synchronize_net() calls.
