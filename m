From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 15:52:18 -0700
Message-ID: <20050422155218.223fa84d.davem@davemloft.net>
References: <4.454130102@selenic.com>
	<5.454130102@selenic.com>
	<17001.31150.194263.732284@segfault.boston.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: jmoyer@redhat.com
In-Reply-To: <17001.31150.194263.732284@segfault.boston.redhat.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, 22 Apr 2005 18:24:46 -0400
Jeff Moyer <jmoyer@redhat.com> wrote:

> ==> Regarding [PATCH 4/7] netpoll: fix ->poll() locking; Matt Mackall <mpm@selenic.com> adds:
> 
> mpm> Introduce a per-client poll lock and flag. The lock assures we never
> mpm> have more than one caller in dev->poll(). The flag provides recursion
> mpm> avoidance on UP where the lock disappears.
> 
> I don't think it makes sense to have the poll lock associated with a struct
> netpoll.

There should be a 1 to 1 relationship from netdev to netpoll, but I see
no problems with a many to 1 relationship from netdev to netpoll, that
is perfectly legal.  It would give more stringent locking on dev->poll()
invocations, not forget to lock when necessary.

The only thing which is wrong is that netpoll_setup() should verify that
netdev->np is NULL, and if it is not it should return an error.
