From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net v3 1/2] net: sched: tbf: fix calculation of max_size
Date: Sun, 24 Nov 2013 10:40:52 -0800
Message-ID: <1385318452.10637.116.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1384845939-8424-1-git-send-email-yangyingliang@huawei.com>
		 <1384845939-8424-2-git-send-email-yangyingliang@huawei.com>
	 <1385233579.10637.95.camel@edumazet-glaptop2.roam.corp.google.com>
	 <5291AA8D.6060108@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Yang Yingliang <yangyingliang@huawei.com>, davem@davemloft.net,
	netdev@vger.kernel.org, brouer@redhat.com, jpirko@redhat.com,
	jbrouer@redhat.com
To: Yang Yingliang <zjutyyl@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f176.google.com ([209.85.192.176]:48339 "EHLO
	mail-pd0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752213Ab3KXSky (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 24 Nov 2013 13:40:54 -0500
Received: by mail-pd0-f176.google.com with SMTP id w10so3997979pde.7
        for <netdev@vger.kernel.org>; Sun, 24 Nov 2013 10:40:53 -0800 (PST)
In-Reply-To: <5291AA8D.6060108@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-11-24 at 15:28 +0800, Yang Yingliang wrote:
> O>
> >> With the follow command:
> >> tc qdisc add dev eth1 root handle 1: tbf latency 50ms burst 10KB rate 30gbit mtu 64k
> >>
> >
> Ideally burst should be 10KB in kernel space.
> But at hight rates, when burst is converted to
> time in tick in userland, it gets much more loss
> than low rates. So the burst can't actually
> reach 10KB in kernel.

If you think tc can help to fix user choices, please provide an
iproute2 patch.

Quite frankly, using a burst of 10KB and a rate of 30gbit is simply a
user error. It cannot possibly work. At all.

As stated in many tbf docs, burst must be larger than device mtu (1514)

By extension, with GRO/GSO, burst should be larger than 68130, otherwise
we need to segment the packets, and this is horribly expensive for high
rates.

I personally tc/tbf needs some changes, because the logical way would be
to use the 1514 value for low rates, but if we use this value, the
kernel gets a value of 1511, which doesn't work.
