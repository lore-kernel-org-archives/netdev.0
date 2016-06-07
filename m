From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH 01/12] net: mediatek: fix DQL support
Date: Tue, 7 Jun 2016 16:20:33 -0700
Message-ID: <CALx6S357KoKbS6tMKUgvHHLowXauZqAXib=bGuJBprwMDFkQ2g@mail.gmail.com>
References: <1465108385-38286-2-git-send-email-john@phrozen.org>
	<20160605.003242.796780762112643713.davem@davemloft.net>
	<e1b52f75-edb7-8504-3e6d-40fcb03e39df@phrozen.org>
	<20160607.160116.2076757909377302163.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: john@phrozen.org,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	linux-mediatek@lists.infradead.org, keyhaede@gmail.com,
	LKML <linux-kernel@vger.kernel.org>, nbd@nbd.name
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160607.160116.2076757909377302163.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Jun 7, 2016 at 4:01 PM, David Miller <davem@davemloft.net> wrote:
> From: John Crispin <john@phrozen.org>
> Date: Mon, 6 Jun 2016 08:43:13 +0200
>
>> i think one solution would be to add some code to have 2 devices share
>> the same dql instance. would that be an acceptable solution ?
>
> You still need to address the issue of synchronization.
>
> dql purposefully doesn't use locking, always because a higher level
> object (in this case the netdev TX queue) it is contained within
> provides the synchronization.
>
> That breaks apart once you share the dql between two netdevs, as you
> are proposing here.  You'll have to add locking, which is expensive.
>
> That's why I'm trying to encourage you to think out of the box and
> find some way to solve the issue without having to access shared
> state shared between multiple devices.
>

I think you guys mean mean BQL not DQL :-)

If two netdevs share the same DMA ring then is using two netdevs the
right approach. Seems like this would have other consequences beyond
BQL...

Tom

> Thanks.
>
