From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: dev->destructor
Date: Mon, 5 May 2003 09:08:20 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030505090820.50cd5a13.shemminger@osdl.org>
References: <20030502.134804.78707298.davem@redhat.com>
	<20030503040949.804182C003@lists.samba.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   acme@conectiva.com.br
Return-path: <netdev-bounce@oss.sgi.com>
To: Rusty Russell <rusty@rustcorp.com.au>
In-Reply-To: <20030503040949.804182C003@lists.samba.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 03 May 2003 14:07:41 +1000
Rusty Russell <rusty@rustcorp.com.au> wrote:

> In message <20030502.134804.78707298.davem@redhat.com> you write:
> >    From: Rusty Russell <rusty@rustcorp.com.au>
> >    Date: Fri, 02 May 2003 15:25:15 +1000
> > 
> >    If this is true, I think you can use the module reference count only,
> >    and your code will be faster, too.  I can prepare the patch for you
> >    later tonight, to see how it looks.
> >    
> > And where do we get the counter from when dev->owner is NULL
> > (ie. non-modular)?  We need the reference counting regardless of
> > whether the device is implemented statically in the kernel or modular.
> 
> But Alexey said you can only call unregister_netdev from module
> unload, ie. if not a module, it can't be unloaded, hence no refcount
> needed.  I wrote the above paragraph because I'm not sure if I
> understood Alexey correctly?

There are several flavors of pseudo-network devices like bridging and VLAN that
dynamically create/destroy netdev's even when they are not modules.
