From: Eyal Perry <eyalpe@mellanox.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Sun, 18 Jan 2015 23:40:59 +0200
Message-ID: <54BC286B.8000605@mellanox.com>
References: <54B54C72.8060705@dev.mellanox.co.il>	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>	 <54B590FB.5040805@dev.mellanox.co.il>	 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>	 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com> <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>, Amir Ancel <amira@mellanox.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Eyal Perry <eyalpe@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-db3on0078.outbound.protection.outlook.com ([157.55.234.78]:15192
	"EHLO emea01-db3-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750838AbbARWHt (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 18 Jan 2015 17:07:49 -0500
In-Reply-To: <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 1/18/2015 19:48 PM, Eric Dumazet wrote:
> On Sun, 2015-01-18 at 18:22 +0200, Eyal Perry wrote:
>
>> Please let me know if you see something in the results.
> Getting high throughput on a single flow means lot of tweaking.
>
> For a start, mlx4 is known to have interrupt mitigation that can hurt,
> as the TX interrupt timer is restarted for every packet that is
> delivered to the NIC.
>
> ethtool -c ethX
> ..
> tx-usecs: 16
> tx-frames: 16
> tx-usecs-irq: 0
> tx-frames-irq: 256
> ...
>
> -> TX IRQ can be delayed by 16*16 = 256 usec.
>
> Can you try :
>
> ethtool -C ethX tx-usecs 2 tx-frames 2
>
> Or even
>
> ethtool -C ethX tx-usecs 1 tx-frames 1
So indeed, interrupt mitigation (tx-usecs 1 tx-frames 1) improves things up
for the "refined TSO autosizing" kernel (from 18.4Gbps to 19.7Gbps). but
in the
other kernel, the BW is remains the same with and without the coalescing.
> Interrupt mitigation is a trade-off.
>
> If one customer wants high throughput on a single flow, then you might
> remove interrupt mitigation.
>
> If another customer wants cpu efficiency with thousand of flows, I guess
> current mlx4 defaults are pretty good.
>
