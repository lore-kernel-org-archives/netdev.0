From: Rusty Russell <rusty@rustcorp.com.au>
Subject: Re: dev->destructor
Date: Wed, 07 May 2003 12:54:22 +1000
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030507035148.270B32C053@lists.samba.org>
References: <20030506.072529.52888036.davem@redhat.com>
Cc: shemminger@osdl.org
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Cc: rusty@rustcorp.com.au, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
In-reply-to: Your message of "Tue, 06 May 2003 07:25:29 MST."
             <20030506.072529.52888036.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In message <20030506.072529.52888036.davem@redhat.com> you write:
>    From: Stephen Hemminger <shemminger@osdl.org>
>    Date: Mon, 5 May 2003 09:08:20 -0700
> 
>    On Sat, 03 May 2003 14:07:41 +1000
>    Rusty Russell <rusty@rustcorp.com.au> wrote:
>    
>    > But Alexey said you can only call unregister_netdev from module
>    > unload, ie. if not a module, it can't be unloaded, hence no refcount
>    > needed.  I wrote the above paragraph because I'm not sure if I
>    > understood Alexey correctly?
> 
>    There are several flavors of pseudo-network devices like bridging
>    and VLAN that dynamically create/destroy netdev's even when they
>    are not modules.
> 
> I think you'll understand what Alexey/Rusty are saying better
> if you consider statically compiled kernel code as a module with
> an implicit non-zero reference count :-)

Yes, but his point is valid.  We *do* want to destroy netdev's at
random times, not just from module cleanup code.  Hotplug, for
example.

So me saying "just rely on the owner refcnt" was wrong.

Rusty.
--
  Anyone who quotes me in their sig is an idiot. -- Rusty Russell.
