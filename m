From: Andi Kleen <ak@suse.de>
Subject: Re: [PATCH] Prevent netpoll hanging when link is down
Date: Fri, 8 Oct 2004 01:50:22 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20041007235022.GB19864@wotan.suse.de>
References: <20041006214322.GG31237@waste.org> <20041007075319.6b31430d@jack.colino.net> <20041006234912.66bfbdcc.davem@davemloft.net> <20041007160532.60c3f26b@pirandello> <20041007112846.5c85b2d9.davem@davemloft.net> <20041007224422.1c1bea95@jack.colino.net> <20041007214505.GB31558@wotan.suse.de> <20041007215025.GT31237@waste.org> <20041007150756.2373719f.davem@davemloft.net> <20041007234322.GW31237@waste.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, ak@suse.de, colin@colino.net,
        akpm@osdl.org, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
Content-Disposition: inline
In-Reply-To: <20041007234322.GW31237@waste.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

> Deadlocks from recursion, presumably? We could probably throw in a max
> retry count, as ugly as that is..

There should not be any recursion, no.

The problem is that the poll is effectively a spinlock. But when
another CPU takes an long interrupt while holding the lock it 
could take quite a long time to grab the lock.

For most network drivers this shouldn't occur though because
the net driver private lock is usually always taken with interrupts
off. 


-Andi
