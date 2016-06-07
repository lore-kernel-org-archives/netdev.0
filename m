From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 01/12] net: mediatek: fix DQL support
Date: Tue, 07 Jun 2016 16:01:16 -0700 (PDT)
Message-ID: <20160607.160116.2076757909377302163.davem@davemloft.net>
References: <1465108385-38286-2-git-send-email-john@phrozen.org>
	<20160605.003242.796780762112643713.davem@davemloft.net>
	<e1b52f75-edb7-8504-3e6d-40fcb03e39df@phrozen.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-mediatek@lists.infradead.org,
	keyhaede@gmail.com, linux-kernel@vger.kernel.org, nbd@nbd.name
To: john@phrozen.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <e1b52f75-edb7-8504-3e6d-40fcb03e39df@phrozen.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Crispin <john@phrozen.org>
Date: Mon, 6 Jun 2016 08:43:13 +0200

> i think one solution would be to add some code to have 2 devices share
> the same dql instance. would that be an acceptable solution ?

You still need to address the issue of synchronization.

dql purposefully doesn't use locking, always because a higher level
object (in this case the netdev TX queue) it is contained within
provides the synchronization.

That breaks apart once you share the dql between two netdevs, as you
are proposing here.  You'll have to add locking, which is expensive.

That's why I'm trying to encourage you to think out of the box and
find some way to solve the issue without having to access shared
state shared between multiple devices.

Thanks.
