From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next v2 0/4] bonding work-queues, try_rtnl() & notifications
Date: Sun, 22 Mar 2015 01:20:11 -0700
Message-ID: <CANP3RGfCk2PtUxEY+oNkMGcTnj=+y++edVyf0S6y5Qo4Z41MwQ@mail.gmail.com>
References: <CAF2d9jhMz4Y1ye_ofkgvXyxUJEpNnLrFjMJhHQXKbf6MSS-OVg@mail.gmail.com>
	<20150321.221631.908834228517236497.davem@davemloft.net>
	<CANP3RGeVhFMSvToY7nTu06+eYyscJyHS=uEswnH9Wh=UNfMscQ@mail.gmail.com>
	<20150321.223637.2214520794734249959.davem@davemloft.net>
	<CAF2d9jjgfPSoBHhvD20K+5i-3ty70+kpNPK8gqe-9HKVkrrVwQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	Veaceslav Falico <vfalico@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Nikolay Aleksandrov <nikolay@redhat.com>,
	Jay Vosburgh <j.vosburgh@gmail.com>,
	Eric Dumazet <edumazet@google.com>,
	linux-netdev <netdev@vger.kernel.org>
To: Mahesh Bandewar <maheshb@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f46.google.com ([209.85.192.46]:35947 "EHLO
	mail-qg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751619AbbCVIUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 22 Mar 2015 04:20:12 -0400
Received: by qgez102 with SMTP id z102so35712069qge.3
        for <netdev@vger.kernel.org>; Sun, 22 Mar 2015 01:20:11 -0700 (PDT)
In-Reply-To: <CAF2d9jjgfPSoBHhvD20K+5i-3ty70+kpNPK8gqe-9HKVkrrVwQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> One major hurdle as I see in this approach is that if a module uses this and
> gets unloaded before the next rtnl-unlock call, it would face catastrophic
> consequences. However it can be avoided but there will be cost to manipulate
> that while the gains are not that great.

One very dirty solution would be to always build the couple functions
that need to be called like this into the kernel proper...

But on second thought I actually don't see the problem - functions get
called *before* mutex is released.
All you need to do is rtnl_lock/unlock post deregistration (of any
code that could add callbacks) in the module exit code. Since you've
already deregistered no-one will add a new callback to the queue, and
since you grab/release the rtnl lock you flush the queue, and you're
clear.
