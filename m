From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] netdev_ops
Date: Fri, 11 Jul 2003 15:58:56 -0400
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030711195856.GB30449@gtf.org>
References: <20030708163042.GL23597@parcelfarce.linux.theplanet.co.uk> <3F0B2D30.4020102@candelatech.com> <20030708212551.GL1939@parcelfarce.linux.theplanet.co.uk> <20030708.150835.78728697.davem@redhat.com> <20030709161520.GW1939@parcelfarce.linux.theplanet.co.uk> <20030711193215.GH16037@gtf.org> <3F0F153C.4040506@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Matthew Wilcox <willy@debian.org>, netdev@oss.sgi.com,
   "David S. Miller" <davem@redhat.com>,
   Arnaldo Carvalho de Melo <acme@conectiva.com.br>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
Content-Disposition: inline
In-Reply-To: <3F0F153C.4040506@candelatech.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Fri, Jul 11, 2003 at 12:51:24PM -0700, Ben Greear wrote:
> >3) The func ptrs _count() are totally bogus.  We have an unconditional
> >indirect reference to a function call which does nothing but return a
> >driver constant.
> >
> >I personally think that having ethtool_ops members manually calling
> >the ->get_drvinfo hook is a _lot_ cleaner than 10,000 foo_count hooks.
> >
> >3.a) Further, we will inevitably be adding more counts in the future.
> >If we wanted to be truly expandable, and you really don't like the
> >counts being in struct ethtool_gdrvinfo, then create a struct
> >ethtool_counts that puts all the constants in one place.
> 
> Suppose we do this, how will we make a user-space app that tries to
> read this be backwards/forwards compatible?

It's trivial to return the existing values in the gdrvinfo struct in
addition to a new ethtool_count struct.  Full ABI compat is maintained.


> >4) I don't see why ethtool.h suddenly needs to include linux/types.h,
> >when it hasn't needed it in all this time until now.
> 
> If we're changing lots of stuff...it would be nice to change the u32
> etc to something that user-space can easily handle, as ethtool.h is
> (for better or worse) being included from user-space.  Minor issue
> again as it can be dealt with via type-defs etc.

ethtool.h isn't included in the "lots of stuff" that is changing
:) As you see from Matthew's patch, all changes to ethtool.h are
non-essential.

Regardless, addressing your point, I consider ethtool.h a
kernel-internal header, that's why it uses internal kernel types.
Anybody who copies it to userspace must deal with that.  It is _not_
intended to be #included directly from userspace.  ethtool (the userland
program) purposefully does its own typedefs and stuff.

	Jeff
