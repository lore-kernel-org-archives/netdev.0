From: Jim Keniston <jkenisto@us.ibm.com>
Subject: Re: [PATCH] [1/2] kernel error reporting (revised)
Date: Fri, 18 Jul 2003 16:29:19 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <3F1882CF.538FE76@us.ibm.com>
References: <Mutt.LNX.4.44.0307181148340.5813-100000@excalibur.intercode.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, davem@redhat.com,
   linux-kernel@vger.kernel.org, netdev@oss.sgi.com, jgarzik@pobox.com,
   alan@lxorguk.ukuu.org.uk, rddunlap@osdl.org, kuznet@ms2.inr.ac.ru,
   jkenisto@us.ibm.com
Return-path: <netdev-bounce@oss.sgi.com>
To: James Morris <jmorris@intercode.com.au>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Jim Keniston wrote:

> James Morris wrote:
> >
> > On Thu, 17 Jul 2003, Jim Keniston wrote:
> >
> > > 3. Given the above, what should the evlog.c caller do when
> > > kernel_error_event_iov() returns -EINPROGRESS?
> > > a. Nothing.  Figure the packet will probably get logged.
> > > b. Just to be safe, report it via printk, the same way we report dropped
> > > packets.
> > > We currently do (a).  (b) would mean that every event logged from IRQ
> > > context would be cc-ed to printk.
> >
> > I don't think this irq detection logic should be added at all here, let
> > the caller reschedule its logging if running in irq context.
> >
> > - James
> > --
> > James Morris
> > <jmorris@intercode.com.au>
>
> Yes, this makes sense.  At the kerror.c level, just return -EDEADLK if in_irq().
> Delay packet delivery (via a tasklet, as before) at the evlog.c level instead.
> That way, we know at the evlog.c level (in the tasklet) whether the event packet
> was delivered to anybody, and can paraphrase it to printk if it wasn't.
>
> Is this the sort of thing you had in mind?
> Jim K

I implemented the above change.  Now, an event logged from an interrupt
handler when nobody's listening to our socket (e.g., during boot) is
paraphrased to printk.  Here are the updated patches:

http://prdownloads.sourceforge.net/evlog/kerror-2.5.75.patch?download
http://prdownloads.sourceforge.net/evlog/evlog-2.5.75.patch?download
http://prdownloads.sourceforge.net/evlog/kerrord.tar.gz?download

Jim K
