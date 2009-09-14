From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Mon, 14 Sep 2009 18:07:20 +0400
Message-ID: <20090914140720.GA8564@ioremap.net>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <20090911204602.GA19371@shareable.org> <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com> <20090912094110.GB24709@ioremap.net> <20090914001759.GB30621@shareable.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Paris <eparis@redhat.com>, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Jamie Lokier <jamie@shareable.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090914001759.GB30621@shareable.org>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 14, 2009 at 01:17:59AM +0100, Jamie Lokier (jamie@shareable.org) wrote:
> > When queue is full or you do not have enough RAM. Both are reported at
> > 'sending' time.
> 
> Can you ->poll() and wait reliably until the queue will accept an skb?
> (A few spurious EAGAINs/ENOBUFs is ok, as long as it's not the norm).

Not that simple and for memory allocation error just can't.

There is no direct access to remote peer sockets, i.e. to userspace
ones, so one will have to lock netlink table and run over listeners and
check whether they can accept the message and wait/poll for queue size
to become big enough. Netlink table and its locking is not exported,
so effectively there is no simple way to do this.

-- 
	Evgeniy Polyakov
