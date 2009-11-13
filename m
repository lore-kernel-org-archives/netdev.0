From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ifb: add multi-queue support
Date: Fri, 13 Nov 2009 06:56:29 +0100
Message-ID: <4AFCF50D.6040106@gmail.com>
References: <4AFA8911.7050204@gmail.com> <4AFBD911.6000900@gmail.com>	 <4AFC0436.9090906@gmail.com> <412e6f7f0911121726t47874807g2223d2f1141818f5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Patrick McHardy <kaber@trash.net>,
	Tom Herbert <therbert@google.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:36243 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752063AbZKMF4f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Nov 2009 00:56:35 -0500
In-Reply-To: <412e6f7f0911121726t47874807g2223d2f1141818f5@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Changli Gao a =A8=A6crit :
> 2009/11/12 Eric Dumazet <eric.dumazet@gmail.com>:
>> I believe this patch is fine, but maybe Jarek concern about workqueu=
e
>> vs tasklet should be addressed...
>>
>> We could use the previous handling in case numtxqs=3D=3D1 , ie use a=
 tasklet
>> instead of a work queue ?
>=20
> I don't think it is a good idea. If we do so, the code will be messy,
> and lost the flexibility of process. In fact, latency isn't a problem
> when system load isn't high, and when system load is high (due to too
> many NIC IRQs), throughput and interaction is more important, and the
> current linux networking subsystem just dose so through the softirqd
> mechanism.
>=20

Messy ? Because of few tests added in code, and branches always
correctly predicted ?

Still some people might rely on tasklet instead of workqueues
and added scheduler stress and latency penalty. Tasklet are softirq
and normally are processed a few nanosecs later than RX softirq,=20
on the same CPU, while with your workqueue, I guess the scheduler will
try to not migrate it, so we add a penalty for light to moderate load.

I guess this new ifb mode would be a regression for them ?

If you dont want to maintain a compatibility mode, maybe you
should introduce a complete new driver, drivers/net/ifbmq.c or ifbwq.c

(multiqueue or workqueue references)
