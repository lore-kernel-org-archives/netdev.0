From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH -net] tls: return -EFAULT if copy_to_user() fails
Date: Fri, 23 Jun 2017 03:58:35 -0700
Message-ID: <1498215515.24295.12.camel@perches.com>
References: <20170623101544.c5bvwe5cd6e46bd5@mwanda>
         <1498213904.24295.10.camel@perches.com>
         <20170623103612.ycduw43oyi6hmtp3@mwanda>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 8bit
Cc: Dave Watson <davejwatson@fb.com>,
        Aviad Yehezkel <aviadye@mellanox.com>,
        Ilya Lesokhin <ilyal@mellanox.com>,
        "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org
To: Dan Carpenter <dan.carpenter@oracle.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <20170623103612.ycduw43oyi6hmtp3@mwanda>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2017-06-23 at 13:36 +0300, Dan Carpenter wrote:
> On Fri, Jun 23, 2017 at 03:31:44AM -0700, Joe Perches wrote:
> > On Fri, 2017-06-23 at 13:15 +0300, Dan Carpenter wrote:
> > > The copy_to_user() function returns the number of bytes remaining but we
> > > want to return -EFAULT here.
> > 
> > because?
> > 
> 
> Rhetorical questions don't work over email.  Are you honestly confused
> by this patch?

There doesn't seem to be a fault here, just a
return of less than the expected number of bytes.

It's non-obvious why -EFAULT is the appropriate
return value.

Why is changing the return value from number of
bytes transferred, even if less than desired,
the right thing to do?  Your commit message
doesn't describe any rationale.

getsockopt says:

For getsockopt(), optlen is a value-result argument, initially containing the size
of the buffer pointed to by optval, and modified on return to indicate the actual
size of the value returned

The generic EFAULT description in getsockopt is:

       EFAULT    The  address  pointed  to by optval is not in a valid part of the
                 process address space.  For getsockopt(), this error may also  be
                 returned  if optlen is not in a valid part of the process address
                 space.

Is tls different?



