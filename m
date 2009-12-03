From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v4] net: Introduce realloc_netdev_mq()
Date: Thu, 03 Dec 2009 22:29:42 +0100
Message-ID: <4B182DC6.5030800@gmail.com>
References: <20091101132017.GA2598@ami.dom.local> <20091102.033533.08766686.davem@davemloft.net> <20091102123029.GA7790@ff.dom.local> <20091102.043907.236634594.davem@davemloft.net> <20091203143918.GA20526@ff.dom.local> <4B17D697.8000105@gmail.com> <20091203163640.GA2584@ami.dom.local> <20091203165449.GA2960@ami.dom.local> <4B17EFE3.4080301@gmail.com> <20091203202937.GA11436@ami.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, mchan@broadcom.com,
	kaber@trash.net, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:56143 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750976AbZLCV3n (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Dec 2009 16:29:43 -0500
In-Reply-To: <20091203202937.GA11436@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jarek Poplawski a =E9crit :
> On Thu, Dec 03, 2009 at 06:05:39PM +0100, Eric Dumazet wrote:
>> Jarek Poplawski a =E9crit :
>>> On Thu, Dec 03, 2009 at 05:36:40PM +0100, Jarek Poplawski wrote:
>>>> On Thu, Dec 03, 2009 at 04:17:43PM +0100, Eric Dumazet wrote:
>>>>> if (realloc_netdev_mq(dev, real_queues))
>>>>> 	dev->real_num_tx_queues =3D real_queues;
>>>>>
>>>>> In this case the memory error is not fatal.
>>>> Good point! We can consider doing this inside the function too?
>>> Hmm... Of course, not exactly this - I mean using min().
>> Sure, allowing to reduce the count in case new allocation failed.
>>
>> And report an error if caller wanted to increase number of queues an=
d allocation failed.
>=20
> Hmm... After re-thinking it looks a bit too complex to me. I think,
> there is no reason to not report this error since in most cases it
> shouldn't be fatal. That's why I skipped this check in the changelog
> example. Unless I miss something?
>=20
> Thanks,
> Jarek P.
> ---------------> (take 4)
>=20
> This patch separates allocation of TX subqueues from alloc_netdev_mq(=
)
> to realloc_netdev_mq() to allow for resizing like in this example:
>=20
> some_nic_probe()
> {
> 	...
> 	dev =3D alloc_etherdev_mq(sizeof(*bp), 1)
> 	...
> 	if (MSI-X_available && device_supports_MSI-X_and_multiqueue)
> 		realloc_netdev_mq(dev, TX_MAX_RINGS)
> 	register_netdev(dev)
> 	...
> }
>=20
> Alternatively, it can be done in reverse order: starting from the
> highest queue_count and reallocating with a lower one.
>=20
> The main difference is to hold in num_tx_queues something that is
> really available, instead of max possible value for all configs, in
> case of drivers allocating net_device at the beginning of the probe.
>=20
> The description of alloc_netdev_mq() is fixed btw.
>=20
> Reported-by: Eric Dumazet <eric.dumazet@gmail.com>
> Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
> Cc: Eric Dumazet <eric.dumazet@gmail.com>

Nice patch, thanks :)

Acked-by: Eric Dumazet <eric.dumazet@gmail.com>


