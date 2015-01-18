From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BW regression after "tcp: refine TSO autosizing"
Date: Sun, 18 Jan 2015 09:48:37 -0800
Message-ID: <1421603317.11734.154.camel@edumazet-glaptop2.roam.corp.google.com>
References: <54B54C72.8060705@dev.mellanox.co.il>
	 <1421175434.4099.21.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAJ3xEMibMzJH-AB7pBnO9qBL4McTdsajqHzxXkadnTf1khNdxA@mail.gmail.com>
	 <54B590FB.5040805@dev.mellanox.co.il>
	 <1421186430.11734.6.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Amir Vadai <amirv@mellanox.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Ido Shamay <idos@mellanox.com>,
	Amir Ancel <amira@mellanox.com>,
	Eyal Perry <eyalpe@mellanox.com>
To: Eyal Perry <eyalpe@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:57110 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751223AbbARRsk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2015 12:48:40 -0500
Received: by mail-ig0-f179.google.com with SMTP id l13so9979160iga.0
        for <netdev@vger.kernel.org>; Sun, 18 Jan 2015 09:48:39 -0800 (PST)
In-Reply-To: <CAM_57Zgx3DoQbQMffAJNMeZHa8Yb8M+JuwEH=1Fo_Xou+DkgcQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2015-01-18 at 18:22 +0200, Eyal Perry wrote:

> 
> Please let me know if you see something in the results.

Getting high throughput on a single flow means lot of tweaking.

For a start, mlx4 is known to have interrupt mitigation that can hurt,
as the TX interrupt timer is restarted for every packet that is
delivered to the NIC.

ethtool -c ethX
..
tx-usecs: 16
tx-frames: 16
tx-usecs-irq: 0
tx-frames-irq: 256
...

-> TX IRQ can be delayed by 16*16 = 256 usec.

Can you try :

ethtool -C ethX tx-usecs 2 tx-frames 2

Or even

ethtool -C ethX tx-usecs 1 tx-frames 1

Interrupt mitigation is a trade-off.

If one customer wants high throughput on a single flow, then you might
remove interrupt mitigation.

If another customer wants cpu efficiency with thousand of flows, I guess
current mlx4 defaults are pretty good.
