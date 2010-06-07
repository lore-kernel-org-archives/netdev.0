From: David Miller <davem@davemloft.net>
Subject: Re: [v5 Patch 1/3] netpoll: add generic support for bridge and
 bonding devices
Date: Mon, 07 Jun 2010 03:01:08 -0700 (PDT)
Message-ID: <20100607.030108.235696592.davem@davemloft.net>
References: <4C062CBD.7090906@redhat.com>
	<20100604191841.GM7497@gospo.rdu.redhat.com>
	<4C0CC29D.9070507@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andy@greyhouse.net, fubar@us.ibm.com, fbl@sysclose.org,
	linux-kernel@vger.kernel.org, mpm@selenic.com,
	netdev@vger.kernel.org, bridge@lists.linux-foundation.org,
	gospo@redhat.com, nhorman@tuxdriver.com, jmoyer@redhat.com,
	shemminger@linux-foundation.org,
	bonding-devel@lists.sourceforge.net
To: amwang@redhat.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C0CC29D.9070507@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cong Wang <amwang@redhat.com>
Date: Mon, 07 Jun 2010 17:57:49 +0800

> Hmm, I still feel like this way is ugly, although it may work.
> I guess David doesn't like it either.

Of course I don't like it. :-)

I suspect the locking scheme will need to be changed.

Besides, if we're going to hack this up and do write lock attempts in
the read locking paths, there is no point in using a rwlock any more.
And I'm personally in disfavor of all rwlock usage anyways (it dirties
the cacheline for readers just as equally for writers, and if the
critically protected code path is short enough, that shared cache
line atomic operation will be the predominant cost).

So I'd say, 1) make this a spinlock and 2) try to use RCU for the
read path.

That would fix everything.
