From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: [PATCH 1/4] Net device error logging, revised
Date: Fri, 29 Aug 2003 14:22:07 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F4FC3FF.8A704B85@us.ibm.com>
References: <3F4A8027.6FE3F594@us.ibm.com>
		<20030826183221.GB3167@kroah.com>
		<3F4BEE68.A6C862C2@us.ibm.com> <20030826180626.50778705.shemminger@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Greg KH <greg@kroah.com>, LKML <linux-kernel@vger.kernel.org>,
   netdev <netdev@oss.sgi.com>, Jeff Garzik <jgarzik@pobox.com>,
   "Feldman, Scott" <scott.feldman@intel.com>,
   Larry Kessler <kessler@us.ibm.com>, Randy Dunlap <rddunlap@osdl.org>,
   Alan Cox <alan@lxorguk.ukuu.org.uk>, Andrew Morton <akpm@osdl.org>,
   Daniel Stekloff <dsteklof@us.ibm.com>, Hien Nguyen <hien@us.ibm.com>,
   jkenisto <jkenisto@us.ibm.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Stephen Hemminger wrote:
> 
> > The following options come to mind:
> > 1. Keep the msg buffer, but make it smaller.  Around 120 bytes would probably be
> > big enough for the vast majority of messages.  (printk() uses a 1024-byte buffer,
> > but it's static -- see #2.)
> >
> > 2. Use a big, static buffer, protected by a spinlock.  printk() does this.
> >
> > 3. Do the whole thing in a macro, as in previous proposals.  The size of the macro
> > expansion could be reduced somewhat by doing the encode-prefix step in a function --
> > something like:
[more on #3 snipped]
> 
> Is there some way to tack copy and prepend what you want onto the format
> string, and add additional arguments to the call to printk?  That way you
> wouldn't need space for the potentially large resulting string, but only
> enough room for the expanded format string.

Interesting idea.  I pondered this for a while.  But even if you postulate 
a varargs version of printk (which doesn't exist), it's not really
feasible to do this in a function.  There's no way for a function to
prepend args to a va_list.  That means you'd have to encode the text of
the prefix as part of the format string, and that would require you to
allocate room for prefix+format, which is still a lot of stack.  Also,
the fact that the interface name itself may contain "%d" or some such
makes it even messier.

Greg K-H thinks #2 is a reasonable solution (you're about to serialize on printk's
lock anyway), so I'll go with that.

Thanks.
Jim
