From: Krishna Kumar <kumarkr@us.ibm.com>
Subject: Re: [PATCH] panic during unregister_netdevice()
Date: Wed, 5 Nov 2003 17:16:10 -0800
Sender: netdev-bounce@oss.sgi.com
Message-ID: <OFB5040D72.623B0B1C-ON88256DD6.0004AB4C@us.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: krkumar@us.ibm.com, netdev@oss.sgi.com,
        Stephen Hemminger <shemminger@osdl.org>
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org





> If the loops runs once or twice that is not a bug, it is possible for
> processes to grab onto the device via rtnetlink queries and similar
> and we have to pause and potentially schedule to deal with that.

Yes. I guess rtnetlink_rcv() calls netdev_run_todo() to handle that case.

> The core problem is that we end up putting the device reference to
> zero a second time, and for that reason we should prevent it by
> holding onto a reference around the entire loop and wait for the
> refcount to drop to '1'.

That was my original intention, but won't a driver that calls
unregister_netdevice() followed by a free_netdev() still panic the
system ? Since the netdev_run_todo() can run after this is done and
derefernce the 'dev'. (Or is the refcount of the dev->kobject going
to be > 1 and hence not freed ? This class/object code is new to me).

Thanks,

- KK
