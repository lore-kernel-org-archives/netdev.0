From: jamal <hadi@cyberus.ca>
Subject: Re: leak in netlink_dump()?
Date: Mon, 18 Nov 2002 21:22:48 -0500 (EST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.GSO.4.30.0211182120210.14927-100000@shell.cyberus.ca>
References: <20021113195334.GM27787@reeler.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Thomas Graf <tgr@reeler.org>
In-Reply-To: <20021113195334.GM27787@reeler.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org



On Wed, 13 Nov 2002, Thomas Graf wrote:

> Hello!
>
> Used Kernel: 2.4.18 (same for 2.4.19pre6)
>
> I think I've found a memory leak in netlink_dump (af_netlink.c):
>
> the netlink callback (sk->protinfo.af_netlink->cb) is allocated
> in the calling funtion netlink_dump_start and is not freed
> after the call to netlink_dump.
>

It shouldnt be. The callback is only destroyed when the dump is complete
i.e nothing to dump anymore (skb->len == 0)

> From my point of view, this is a memory leak, but I'm new to
> kernel code and I might be telling shit.

Look carefully at places where netlink_dump is being invoked from and
youll get it.

cheers,
jamal
