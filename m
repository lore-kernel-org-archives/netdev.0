From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: GRO aggregation
Date: Thu, 13 Sep 2012 15:22:12 +0200
Message-ID: <1347542532.13103.1550.camel@edumazet-glaptop>
References: <504F4063.9030706@mellanox.com>
	 <1347388396.13103.658.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622022@MTRDAG01.mtl.com>
	 <1347390113.13103.660.camel@edumazet-glaptop>
	 <36F7E4A28C18BE4DB7C86058E7B607241E622083@MTRDAG01.mtl.com>
	 <1347392132.13103.663.camel@edumazet-glaptop>
	 <505054AE.9040901@mellanox.com>
	 <1347442394.13103.703.camel@edumazet-glaptop> <50509F30.30402@mellanox.com>
	 <5050B6FF.5050002@hp.com> <5050B9B2.5070107@mellanox.com>
	 <5050BDB5.8090200@hp.com> <50517F01.9050501@mellanox.com>
	 <1347523865.13103.1423.camel@edumazet-glaptop>
	 <CAJZOPZL8qrqYfAvcQBDB9CFy7WwztWchaMyADGBnwKpW-r1Q4g@mail.gmail.com>
	 <1347537926.13103.1530.camel@edumazet-glaptop>
	 <CAJZOPZLgQVq+pS1PTU2SM2C_dPPuHx8EnVL8zH077zm5O9aafQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Shlomo Pongartz <shlomop@mellanox.com>,
	Rick Jones <rick.jones2@hp.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Yevgeny Petrilin <yevgenyp@mellanox.co.il>
To: Or Gerlitz <or.gerlitz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:51242 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213Ab2IMNWS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Sep 2012 09:22:18 -0400
Received: by bkwj10 with SMTP id j10so538874bkw.19
        for <netdev@vger.kernel.org>; Thu, 13 Sep 2012 06:22:17 -0700 (PDT)
In-Reply-To: <CAJZOPZLgQVq+pS1PTU2SM2C_dPPuHx8EnVL8zH077zm5O9aafQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-13 at 15:47 +0300, Or Gerlitz wrote:
> Shlomo is dealing with making the IPoIB driver work well with GRO,
> thanks for the
> comments on the Mellanox Ethernet driver, we will look there too
> (added Yevgeny)...
> 
> As for IPoIB it has two modes, connected which irrelevant for this
> discussion, and datagram
> - who is under the  scope here. Its MTU is typically 2044 but can be
> 4092 as well, the allocation
> of skb's for this mode is done in ipoib_alloc_rx_skb() -- which you've
> patched recently...
> 
> Following your comment we noted that if using the lower/typical mtu of
> 2044 which means
> we are below the ipoib_ud_need_sg() threshold, skbs are allocated on
> one "form" and if using
> the 4092 mtu in another "form" - do you see each of the form to fall
> into different GRO flow, e.g
> 2044 to the "slow" and 4092 to the "fast"?!

Seems fine to me both ways, because you use dev_alloc_skb(), and you
dont pull tcp payload into tcp->head.

You might try adding prefetch() as well to bring into cpu cache
IP/TCP headers before they are needed in gro layers.
