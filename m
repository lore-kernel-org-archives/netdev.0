From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
 possible after transfer
Date: Mon, 07 Jun 2010 11:58:00 +0200
Message-ID: <1275904680.2545.44.camel@edumazet-laptop>
References: <1275536881.18536.5.camel@eight.analog.com>
	 <AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
	 <1275624354.2533.121.camel@edumazet-laptop>
	 <AANLkTimO47rtvIwYAwpaMYtK5SEnhM0m3AxL5q-8lvA7@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: Sonic Zhang <sonic.adi@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:48804 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752231Ab0FGJ6F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 7 Jun 2010 05:58:05 -0400
Received: by fxm8 with SMTP id 8so1902408fxm.19
        for <netdev@vger.kernel.org>; Mon, 07 Jun 2010 02:58:03 -0700 (PDT)
In-Reply-To: <AANLkTimO47rtvIwYAwpaMYtK5SEnhM0m3AxL5q-8lvA7@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 04 juin 2010 =C3=A0 12:44 +0800, Sonic Zhang a =C3=A9crit :

>=20
> Yes, you are right. dev_kfree_skb_irq() queues used skb to the
> complete queue. But, it is actually freed in the other soft irq
> NET_TX_SOFTIRQ.

I guess you didnt understood my mail, so I'll re-explain :

dev_kfree_skb_irq() queues skb only if packet is not already orphaned.

As most packets are now orphaned (in recent kernels where your patch
applies), dev_kfree_skb_irq() can free packet immediately, with no
NET_TX_SOFTIRQ overhead.



