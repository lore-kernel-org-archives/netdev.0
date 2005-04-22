From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 19:02:43 -0400
Message-ID: <17001.33427.462497.856777@segfault.boston.redhat.com>
References: <4.454130102@selenic.com>
	<5.454130102@selenic.com>
	<17001.31150.194263.732284@segfault.boston.redhat.com>
	<20050422155218.223fa84d.davem@davemloft.net>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mpm@selenic.com, jgarzik@pobox.com, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20050422155218.223fa84d.davem@davemloft.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

==> Regarding Re: [PATCH 4/7] netpoll: fix ->poll() locking; "David S. Miller" <davem@davemloft.net> adds:

davem> On Fri, 22 Apr 2005 18:24:46 -0400 Jeff Moyer <jmoyer@redhat.com>
davem> wrote:

>> ==> Regarding [PATCH 4/7] netpoll: fix ->poll() locking; Matt Mackall
>> <mpm@selenic.com> adds:
>> 
mpm> Introduce a per-client poll lock and flag. The lock assures we never
mpm> have more than one caller in dev->poll(). The flag provides recursion
mpm> avoidance on UP where the lock disappears.
>> I don't think it makes sense to have the poll lock associated with a
>> struct netpoll.

davem> There should be a 1 to 1 relationship from netdev to netpoll, but I
davem> see no problems with a many to 1 relationship from netdev to
davem> netpoll, that is perfectly legal.  It would give more stringent
davem> locking on dev->poll() invocations, not forget to lock when
davem> necessary.

davem> The only thing which is wrong is that netpoll_setup() should verify
davem> that netdev-> np is NULL, and if it is not it should return an error.

Oh yes, of course.  Somehow I managed to forget that we now squirrel away
the struct netpoll pointer in the net_device.  Previously you could
register multiple netpoll clients to one device, and this was useful for
say doing netconsole and netdump over the same interface.  If we've removed
this ability, this is a bad thing.  Oh dear...

-Jeff
