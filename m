From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/8] networking/fanotify: declare fanotify socket
 numbers
Date: Fri, 11 Sep 2009 11:46:20 -0700 (PDT)
Message-ID: <20090911.114620.260824240.davem@davemloft.net>
References: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-fsdevel@vger.kernel.org,
	netdev@vger.kernel.org, viro@zeniv.linux.org.uk,
	alan@linux.intel.com, hch@infradead.org
To: eparis@redhat.com
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <20090911052558.32359.18075.stgit@paris.rdu.redhat.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Paris <eparis@redhat.com>
Date: Fri, 11 Sep 2009 01:25:58 -0400

> fanotify's user interface uses a custom socket (it doesn't use netlink
> since work must be done in the context of the receive side of the socket)
> 
> This patch simply defines the fanotify socket number declarations.  The
> actual implementation of the socket is in a later patch.
> 
> Signed-off-by: Eric Paris <eparis@redhat.com>

I would really prefer if you worked on eliminating the problem that
prevents you from using netlink instead.

You're just duplicating tons of netlink functionality only because of
this apparent limitation, and that's not good.

If you use netlink you'll be able to define arbitrary attributes,
they'll be optional and thus you can allow notification application to
set filters on those attributes, as well as all sorts of other things.

You can reimplement that, but I really would rather see you make
netlink suit your needs.  This is how we make existing facilities
more powerful and useful to consumers, when someone tries to use
it in a new way and with new requirements.

Thanks.
