From: Thomas Graf <tgraf@suug.ch>
Subject: Re: [Lse-tech] Re: A common layer for Accounting packages
Date: Mon, 28 Feb 2005 03:32:06 +0100
Message-ID: <20050228023206.GN31837@postel.suug.ch>
References: <421993A2.4020308@ak.jp.nec.com> <421B955A.9060000@sgi.com> <421C2B99.2040600@ak.jp.nec.com> <421CEC38.7010008@sgi.com> <421EB299.4010906@ak.jp.nec.com> <20050224212839.7953167c.akpm@osdl.org> <20050227094949.GA22439@logos.cnet> <4221E548.4000008@ak.jp.nec.com> <20050227140355.GA23055@logos.cnet> <42227AEA.6050002@ak.jp.nec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Marcelo Tosatti <marcelo.tosatti@cyclades.com>,
        Andrew Morton <akpm@osdl.org>, davem@redhat.com, jlan@sgi.com,
        lse-tech@lists.sourceforge.net, linux-kernel@vger.kernel.org,
        netdev@oss.sgi.com
To: Kaigai Kohei <kaigai@ak.jp.nec.com>
Content-Disposition: inline
In-Reply-To: <42227AEA.6050002@ak.jp.nec.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

First of all, I'm not aware of the whole discussion, ignore this if it
has been brought to attention already.

> > Yep, the netlink people should be able to help - they known what would be
> > required for not sending messages in case there is no listener registered.
> >
> > Maybe its already possible? I have never used netlink myself.

The easiest way is to use netlink_broadcast() and have userspace
register to a netlink multicast group (set .nl_groups before connecting
the socket). The netlink message will be sent to only those netlink
sockets assigned to the group, no message will be send out if no
userspace listeners has registered.

Did you have a look at the syscall enter/exit audit netlink hooks
before trying to invent your own thing?

I can also give you some code if you want, I use it to track the path
of skbs in the net stack. It puts events into a preallocated ring buffer
and a separate kernel thread broadcasts them over netlink. The events
can be enqueued in any context at the cost of a possible ring buffer
overrun resulting in loss of events. It's just a debugging hack though.
