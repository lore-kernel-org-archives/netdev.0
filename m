From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 12:16:26 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015191626.GD15420@kroah.com>
References: <20021015.104014.34145167.davem@redhat.com> <Pine.LNX.4.44.0210151353450.1159-100000@beohost.scyld.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@redhat.com>, jmorris@intercode.com.au,
   kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Donald Becker <becker@scyld.com>
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.44.0210151353450.1159-100000@beohost.scyld.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2002 at 02:14:01PM -0400, Donald Becker wrote:
>   - Your method adds a bunch of hooks when just one would do.

How would you propose a single hook?  Specify the action in the hook?
Linus has already rejected this idea :)

> The usual approach is
>    if (obj->hookfun)  obj->hookfun(obj, method_index, other_params);
> 
> Even this makes the code less readable, but at least doesn't jump all
> over the instruction space.  The impact is a dereference and a test for
> zero, and then a jump over a push/mov instructions for values that
> should already be in registers.

Linus has stated that he didn't want the check and then jump, but an
unconditional jump (even if the function is nothing but a return.)  I
guess this is faster as the processor doesn't have to guess at branch
prediction.  That's why we built these calls in this way.

That being said, a number of people have asked that the networking hooks
be able to "be compiled away", so we will be glad to do this.

thanks,

greg k-h
