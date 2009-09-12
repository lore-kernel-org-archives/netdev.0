From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket numbers
Date: Sat, 12 Sep 2009 13:41:10 +0400
Message-ID: <20090912094110.GB24709@ioremap.net>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com> <20090911.114620.260824240.davem@davemloft.net> <1252697613.2305.38.camel@dhcp231-106.rdu.redhat.com> <20090911204602.GA19371@shareable.org> <1252703626.2305.50.camel@dhcp231-106.rdu.redhat.com> <20090911212731.GA19901@shareable.org> <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jamie Lokier <jamie@shareable.org>,
	David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: Eric Paris <eparis@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tservice.net.ru ([195.178.208.66]:35637 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752318AbZILJlJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 12 Sep 2009 05:41:09 -0400
Content-Disposition: inline
In-Reply-To: <1252705902.2305.83.camel@dhcp231-106.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 11, 2009 at 05:51:42PM -0400, Eric Paris (eparis@redhat.com) wrote:
> For some things yes, some things no.  I'd have to understand where loss
> can happen to know if it's feasible.  If I know loss happens in the
> sender context that's great.  If it's somewhere in the middle and the
> sender doesn't immediately know it'll never be delivered, yes, I don't
> think it can solve all my needs.  How many places can and skb get lost
> between the sender and the receiver?

When queue is full or you do not have enough RAM. Both are reported at
'sending' time.

As of your description of netlink/socket usage - you will have to peek
skb queue, which is rather error-prone operation. Also you will have to
implement own skb destructor to mess with private reference counters and
netlink bits.

-- 
	Evgeniy Polyakov
