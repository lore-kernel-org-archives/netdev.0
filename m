From: Greg KH <greg@kroah.com>
Subject: Re: [PATCH] LSM networking: skb hooks for 2.5.42 (2/7)
Date: Tue, 15 Oct 2002 13:12:09 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20021015201209.GE15864@kroah.com>
References: <20021015191626.GD15420@kroah.com> <20021015.123443.62397799.davem@redhat.com> <20021015194545.GC15864@kroah.com> <20021015.124502.130514745.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: becker@scyld.com, jmorris@intercode.com.au, kuznet@ms2.inr.ac.ru,
   netdev@oss.sgi.com, linux-security-module@wirex.com
Return-path: <netdev-bounce@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
Content-Disposition: inline
In-Reply-To: <20021015.124502.130514745.davem@redhat.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Tue, Oct 15, 2002 at 12:45:02PM -0700, David S. Miller wrote:
>    From: Greg KH <greg@kroah.com>
>    Date: Tue, 15 Oct 2002 12:45:45 -0700
> 
>    Fair enough, mind if I create a CONFIG_SECURITY_NETWORK that we can use
>    for this?
>    
> Why special case networking?  Do it for everything.
> 
> 2.5.x can use all the help it can get in the debloating
> department.  It's currently busting at the seams.
> 
> security/*.o takes up space in my kernel and achieves ABSOLUTELY
> NOTHING but take up space, the same goes for all the security_ops->()
> invocations all over the place.

Those invocations also take up no measurable time :)

Yes, the size of the *.o files in the security directory can be shrunk a
bit:
   text    data     bss     dec     hex filename
   6765     776       8    7549    1d7d built-in.o
   3280     392       4    3676     e5c capability.o
   1772     384       0    2156     86c dummy.o
   1713       0       4    1717     6b5 security.o

The majority of this size is the multiple "NULL" hook functions.  The
developers have had a few ideas on how to fix this issue, and will be
worked on.  I can also shrink security.o by fixing a function that
doesn't need to be inlined.  But most of the logic in capability.o
previously used to be in kernel/capability.c, and that file has shrunk a
bit.

> You must allow the user to config this stuff out of their tree.

No, I only think the network stuff should be allowed to be compiled
away, not the other hooks (ipc and vfs).

We will work on this, and submit a network patch that is able to be
compiled away.

BTW, is the existing security value in struct skbuff used for anything?
I see where it is set to zero, and then copied a few times, but never
set.  Am I missing something?

thanks,

greg k-h
