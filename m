From: Bob Wirka <bobwirka@rtcworks.com>
Subject: Re: NFS and Network Driver Question
Date: Tue, 19 Oct 2004 13:03:16 -0500
Sender: netdev-bounce@oss.sgi.com
Message-ID: <417556E4.4090406@rtcworks.com>
References: <41704198.8000206@rtcworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, linux-net@vger.kernel.org
Return-path: <netdev-bounce@oss.sgi.com>
In-Reply-To: <41704198.8000206@rtcworks.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Please disregard my last post, I believe the problem is solved. Thanks 
again to all, especially Thomas Graf.

The essential things to learn from this exercise are:

1. A network driver compiled into the kernel must have an initialization 
function that allocates the 'net_device' structure and passes this to 
the kernel through the 'register_netdev()' call. You can reuse the 
module-version initialization function; rename it and prefix it's 
declaration with 'static __init'.

2. Add the 'module_init( init_fcn )' macro after the initialization 
function. This will cause the kernel to execute that code when booting.

Onward and upward.

Bob Wirka
Realtime Control Works

Bob Wirka wrote:

> Hello,
>
> I'm trying to build a kernel that mounts a NFS root file system. This 
> is an embedded system; it uses an SMSC LAN91C111 network chip that is 
> hardwired to I/O addres 0x300 and IRQ 5. I've been using the driver 
> (as supplied by SMSC) as a module, and it works fine. Now I'm trying 
> to incorporate it into the kernel build so that I can mount an NFS 
> file system when the system boots.
>
> I've added the source code to the kernel tree, and modified the 
> Makefile(s) and Config.in files so that the driver <<appears>> to be 
> compiled into the kernel. The kernel will load, but the chip is not 
> initialized and the NFS fails.
>
> Since I don't know how to pass the io address and irq number to the 
> kernel, I've hard-coded them into the driver's init function (which I 
> don't see being called).
>
> If someone could point me in the right direction, I'd appreciate it.
>
> Thank you,
>
> Bob Wirka
> Realtime Control Works
>
>
